# mithril-runtime

A trimmed-down distribution of Mithril that keeps `m()`, components, virtual
rendering, `m.mount`, `m.redraw`, `m.render`, and `m.fragment` — the render
runtime, nothing else. Versioned independently of Mithril itself (regular
semver, starting at `1.0.0`); the upstream Mithril release it's currently
built from is recorded in `package.json`'s `upstreamMithrilVersion` field
(currently `2.3.8`), not in this package's own version number.

It does not include or expose `m.route`, `m.trust`, or `m.request`. As a
result, there is no router, no unescaped-HTML insertion, and no built-in HTTP
client — the three things that only make sense inside a browser. Meant for
consumers that retarget Mithril's `render()` to an environment that isn't the
browser DOM (see
[`mithril-lynx`](https://github.com/carlos-sweb/mithril-lynx)).

```js
var m = require("mithril-runtime")

m.mount(document.body, {
  view: function () {
    return m("main", [m("h1", "Hello"), m("p", "mithril-runtime")])
  },
})
```

## Why this exists

This package was born out of [`mithril-lynx`](https://github.com/carlos-sweb/mithril-lynx),
which retargets Mithril's render pipeline to [Lynx](https://lynxjs.org)
instead of a browser DOM. `mithril-lynx` needs exactly one thing from
Mithril: `render/render.js`'s factory and its `render(dom, vnodes, redraw)`
contract, run against a Lynx-backed fake DOM — nothing more.

Plain `mithril` still carries `m.route` (a `pushState`/`hashchange` router),
`m.trust` (raw HTML insertion), and `m.request` (an XHR/fetch-based HTTP
client). All three assume a real browser: a router needs `window.location`
and browser history, trusted HTML needs an `innerHTML` sink, and the request
client is just a `fetch`/`XMLHttpRequest` wrapper. None of that means
anything on Lynx's main/background thread split — there's no address bar, no
DOM to inject raw HTML into, and no reason to duplicate an HTTP client Lynx
already provides on its own terms. Depending on plain `mithril` would mean
shipping and maintaining compatibility with code that can never run, for no
benefit.

So instead of forking `mithril` again for `mithril-lynx` (and every future
port to a non-browser target), the browser-only third got extracted into its
own reusable core: `mithril-runtime`. It's a plain, mostly-unmodified subset
of upstream Mithril — see the "Updating from Mithril.js" section below for
exactly what gets removed and how that removal is kept honest across
updates.

## Development

Run `bun run test` to check the reduced API surface, basic rendering, and that
text HTML isn't interpreted. `bun run build` generates the browser artifact
`mithril-runtime.js`.

## Updating from Mithril.js

The reproducible procedure lives in
[`scripts/update-from-mithril.sh`](scripts/update-from-mithril.sh). It
downloads an official tag, copies only the necessary core, removes the
router, requests, and trusted HTML, validates that no references remain, and
runs tests and the build.

```bash
# Latest version, configured by default
bun run update:mithril

# A specific Mithril tag
bash scripts/update-from-mithril.sh v2.3.9

# From a local checkout, no network
bash scripts/update-from-mithril.sh ignored /path/to/mithril.js
```

The script fails if the upstream structure changes, so it never publishes a
version that only partially removed the excluded features. It updates
`upstreamMithrilVersion` automatically but never touches this package's own
`version` — bump that yourself, based on what actually changed, before
publishing.

The code comes from Mithril.js and is distributed under the MIT license; see
`LICENSE` in the official project for the full text.
