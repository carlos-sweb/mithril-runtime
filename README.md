# mithril-runtime

A trimmed-down distribution of Mithril 2.3.8 that keeps `m()`, components,
virtual rendering, `m.mount`, `m.redraw`, `m.render`, and `m.fragment` — the
render runtime, nothing else.

It does not include or expose `m.route`, `m.trust`, or `m.request`. As a
result, there is no router, no unescaped-HTML insertion, and no built-in HTTP
client — the three things that only make sense inside a browser. Meant for
consumers that retarget Mithril's `render()` to an environment that isn't the
browser DOM (see
[`mithril-lynx-v2`](https://github.com/carlos-sweb/mithril-lynx-v2)).

```js
var m = require("mithril-runtime")

m.mount(document.body, {
  view: function () {
    return m("main", [m("h1", "Hello"), m("p", "mithril-runtime")])
  },
})
```

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
version that only partially removed the excluded features.

The code comes from Mithril.js and is distributed under the MIT license; see
`LICENSE` in the official project for the full text.
