ElementFactory = require './elementFactory'

exports.before = (decorator) -> (method) -> ->
  decorator.apply this, arguments
  method.apply this, arguments

exports.after = (decorator) -> (method) -> ->
  method.apply this, arguments
  decorator.apply this, arguments

# Decorate method to support chaining.
#
#     // in console
#     > o = {}
#     > o.hello = "Hello"
#     > o.foo = chainable(function(){console.log(this.hello + " World")});
#     > o.foo().hello
#     Hello World
#     "Hello"
#
exports.chainable = exports.after -> this

exports.onlyWith$ = (fn) -> if jQuery? || Zepto?
 do ($ = jQuery || Zepto) -> fn arguments

exports.getElements = (el) ->
  elements = []
  _getElements el, elements
  elements

_getElements = (template, elements) ->
  child = template.firstChild
  while child
    if child.nodeType == exports.ELEMENT_NODE
      elements.push new ElementFactory.createElement(child)
      _getElements child, elements

    child = child.nextSibling

exports.ELEMENT_NODE = 1
exports.TEXT_NODE    = 3

# IE8 <= fails to clone detached nodes properly, shim with jQuery
# jQuery.clone: https://github.com/jquery/jquery/blob/master/src/manipulation.js#L594
# jQuery.support.html5Clone: https://github.com/jquery/jquery/blob/master/src/support.js#L83
html5Clone = () -> document.createElement('nav').cloneNode(true).outerHTML != '<:nav></:nav>'
exports.cloneNode  =
  if not document? or html5Clone()
    (node) -> node.cloneNode true
  else
    (node) ->
      cloned = Transparency.clone(node)
      if cloned.nodeType == exports.ELEMENT_NODE
        cloned.removeAttribute expando
        for element in cloned.getElementsByTagName '*'
          element.removeAttribute expando
      cloned

# Minimal implementation of jQuery.data
#
#     // in console
#     > template = document.getElementById('template')
#     > data(template).hello = 'Hello World!'
#     > console.log(data(template).hello)
#     Hello World!
#
# Expanding DOM element with a JS object is generally unsafe.
# However, as references to expanded DOM elements are never lost, no memory leaks are introduced
# http://perfectionkills.com/whats-wrong-with-extending-the-dom/
expando = 'transparency'
exports.data    = (element) -> element[expando] ||= {}

exports.nullLogger    = () ->
exports.consoleLogger = -> console.log arguments
exports.log           = exports.nullLogger
