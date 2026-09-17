#!/usr/bin/env bash
# Regenera mithril-runtime a partir de una etiqueta o checkout de Mithril.js.
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
REF=${1:-v2.3.8}
SOURCE=${2:-}
RUNTIME=${RUNTIME:-bun}

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
require_file() { [ -f "$1" ] || die "No existe el archivo esperado: $1"; }

if ! command -v "$RUNTIME" >/dev/null; then
	if [ "$RUNTIME" = bun ] && command -v node >/dev/null; then RUNTIME=node
	else die "No se encontró el runtime '$RUNTIME'"; fi
fi

TEMP_DIR=
cleanup() { [ -z "$TEMP_DIR" ] || rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

if [ -n "$SOURCE" ]; then
	SOURCE=$(cd "$SOURCE" && pwd)
else
	TEMP_DIR=$(mktemp -d)
	SOURCE="$TEMP_DIR/mithril.js"
	git clone --depth 1 --branch "$REF" https://github.com/MithrilJS/mithril.js.git "$SOURCE"
fi

for file in \
	"$SOURCE/index.js" "$SOURCE/package.json" "$SOURCE/LICENSE" \
	"$SOURCE/api/mount-redraw.js" "$SOURCE/render/render.js" \
	"$SOURCE/render/hyperscript.js" "$SOURCE/render/fragment.js" \
	"$SOURCE/render/hyperscriptVnode.js" "$SOURCE/render/vnode.js" \
	"$SOURCE/render/domFor.js" "$SOURCE/render/delayedRemoval.js" \
	"$SOURCE/render/emptyAttrs.js" "$SOURCE/render/cachedAttrsIsStaticMap.js" \
	"$SOURCE/util/censor.js" "$SOURCE/util/hasOwn.js" \
	"$SOURCE/test-utils/domMock.js" "$SOURCE/scripts/bundler.js" \
	"$SOURCE/scripts/_bundler-impl.js"; do
	require_file "$file"
done

cd "$ROOT"
rm -rf render route.js request.js request api/router.js
mkdir -p api util test-utils
cp -R "$SOURCE/render" ./render
rm -rf render/tests render/trust.js
cp "$SOURCE/LICENSE" ./LICENSE
cp "$SOURCE/api/mount-redraw.js" ./api/mount-redraw.js
cp "$SOURCE"/{browser.js,hyperscript.js,mount-redraw.js,mount.js,redraw.js,render.js} ./
cp "$SOURCE/util"/{censor.js,hasOwn.js} ./util/
cp "$SOURCE/test-utils/domMock.js" ./test-utils/domMock.js
cp "$SOURCE/scripts"/{bundler.js,_bundler-impl.js} ./scripts/

# Quitar la fábrica pública de VNodes HTML confiables.
grep -Fq 'hyperscript.trust = require("./render/trust")' hyperscript.js || die 'La estructura de hyperscript.js cambió'
sed -i '/hyperscript\.trust = require("\.\/render\/trust")/d' hyperscript.js

# Quitar el renderer de HTML confiable, incluso ante un VNode creado manualmente.
sed -i '/case "<": createHTML(parent, vnode, ns, nextSibling); break/d' render/render.js
sed -i '/case "<": updateHTML(parent, old, vnode, ns, nextSibling); break/d' render/render.js

remove_block() {
	local file=$1 start=$2 end=$3 temp
	temp=$(mktemp)
	awk -v start="$start" -v end="$end" '
		$0 == start { removing = 1; found = 1; next }
		removing && $0 == end { removing = 0; print; next }
		!removing { print }
		END { if (!found || removing) exit 1 }
	' "$file" > "$temp" || { rm -f "$temp"; die "La estructura de $file cambió"; }
	mv "$temp" "$file"
}

remove_block render/render.js \
	$'\tvar possibleParents = {caption: "table", thead: "table", tbody: "table", tfoot: "table", tr: "tbody", th: "tr", td: "tr", colgroup: "table", col: "colgroup"}' \
	$'\tfunction createFragment(parent, vnode, hooks, ns, nextSibling) {'
remove_block render/render.js \
	$'\tfunction updateHTML(parent, old, vnode, ns, nextSibling) {' \
	$'\tfunction updateFragment(parent, old, vnode, hooks, nextSibling, ns) {'

grep -Fq 'Child node of a contenteditable must be trusted.' render/render.js || die 'La estructura de contenteditable cambió'
sed -i '/if (children != null && children.length === 1 && children\[0\].tag === "<") {/,/else if (children != null && children.length !== 0) throw new Error("Child node of a contenteditable must be trusted.")/c\
\t\tif (children != null && children.length !== 0) throw new Error("A contenteditable element cannot have virtual children in this build.")' render/render.js

UPSTREAM_VERSION=$(sed -n 's/.*"version": "\([^"]*\)".*/\1/p' "$SOURCE/package.json" | head -n 1)
[ -n "$UPSTREAM_VERSION" ] || die 'No se pudo detectar la versión de Mithril'
# mithril-runtime tracks ITS OWN semver (bump it yourself before publishing,
# based on what actually changed) — only the tracked upstream tag is
# recorded automatically here, so a plain `npm install mithril-runtime` /
# `^x.y.z` range keeps working normally for consumers instead of landing on
# a prerelease tag they need to special-case.
sed -i -E "s/\"upstreamMithrilVersion\": \"[^\"]*\"/\"upstreamMithrilVersion\": \"${UPSTREAM_VERSION}\"/" package.json

if rg -n 'm\.(route|trust|request)|hyperscript\.trust|createHTML|updateHTML|innerHTML' \
	index.js hyperscript.js browser.js render mithril-runtime.js; then
	die 'La exclusión de funcionalidades no se completó'
fi
"$RUNTIME" tests/runtime.test.js
"$RUNTIME" scripts/bundler browser.js -output mithril-runtime.js
printf 'mithril-runtime regenerado desde %s (upstream Mithril %s). Recordá bumpear "version" en package.json antes de publicar.\n' "$SOURCE" "$UPSTREAM_VERSION"
