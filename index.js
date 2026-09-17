"use strict"

// mithril-runtime intentionally exposes only the rendering runtime.
// Routing, trusted HTML and HTTP requests are omitted from this build.
var hyperscript = require("./hyperscript")
var mountRedraw = require("./mount-redraw")

function m() { return hyperscript.apply(this, arguments) }

m.m = hyperscript
m.fragment = hyperscript.fragment
m.Fragment = "["
m.mount = mountRedraw.mount
m.render = require("./render")
m.redraw = mountRedraw.redraw
m.vnode = require("./render/vnode")
m.censor = require("./util/censor")
m.domFor = require("./render/domFor")

module.exports = m
