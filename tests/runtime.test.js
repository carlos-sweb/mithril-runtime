"use strict"

var assert = require("assert")
var m = require("../index")
var domMock = require("../test-utils/domMock")

assert.strictEqual(typeof m, "function")
assert.strictEqual(m.route, undefined, "m.route must not be part of the minimal API")
assert.strictEqual(m.trust, undefined, "m.trust must not be part of the minimal API")
assert.strictEqual(m.request, undefined, "m.request must not be part of the minimal API")

var $window = domMock()
var root = $window.document.createElement("main")
m.render(root, m("button.primary", {type: "button"}, "Guardar"))

assert.strictEqual(root.firstChild.nodeName, "BUTTON")
assert.strictEqual(root.firstChild.className, "primary")
assert.strictEqual(root.firstChild.firstChild.nodeValue, "Guardar")

m.render(root, m("p", "<em>texto sin interpretar</em>"))
assert.strictEqual(root.firstChild.nodeName, "P")
assert.strictEqual(root.firstChild.firstChild.nodeValue, "<em>texto sin interpretar</em>")

// pathname/querystring: pure route-template utilities, kept even though
// m.route itself is excluded — a consumer building its own router (e.g.
// mithril-lynx-v2's in-memory route.js) needs the exact same `:id`/`:file...`
// template syntax real Mithril uses, without pulling in window.history.
var compileTemplate = require("../pathname/compileTemplate")
var parsePathname = require("../pathname/parse")
var buildPathname = require("../pathname/build")

var check = compileTemplate("/users/:id")
var matched = parsePathname("/users/42")
assert.strictEqual(check(matched), true, "compileTemplate must match a concrete path")
assert.strictEqual(matched.params.id, "42", "compileTemplate must extract :id")
assert.strictEqual(buildPathname("/users/:id", { id: 42 }), "/users/42", "build must interpolate params")

console.log("mithril-runtime: all tests passed")
