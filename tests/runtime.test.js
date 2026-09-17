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

console.log("mithril-runtime: all tests passed")
