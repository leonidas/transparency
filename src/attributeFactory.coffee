_       = require '../lib/lodash'
helpers = require './helpers'

module.exports = AttributeFactory =
  Attributes: {}

  createAttribute: (element, name) ->
    Attr = AttributeFactory.Attributes[name] or Attribute
    new Attr(element, name)


class Attribute
  constructor: (@el, @name) ->
    @templateValue = @el.getAttribute(@name) || ''

  set: (value) ->
    @el[@name] = value
    @el.setAttribute @name, value.toString()


class BooleanAttribute extends Attribute
  BOOLEAN_ATTRIBUTES = ['hidden', 'async', 'defer', 'autofocus', 'formnovalidate', 'disabled',
    'autofocus', 'formnovalidate', 'multiple', 'readonly', 'required', 'checked', 'scoped',
    'reversed', 'selected', 'loop', 'muted', 'autoplay', 'controls', 'seamless', 'default',
    'ismap', 'novalidate', 'open', 'typemustmatch', 'truespeed']

  for name in BOOLEAN_ATTRIBUTES
    AttributeFactory.Attributes[name] = this

  constructor: (@el, @name) ->
    @templateValue = @el.getAttribute(@name) || false

  set: (value) ->
    @el[@name] = value
    if value
    then @el.setAttribute @name, @name
    else @el.removeAttribute @name


class Text extends Attribute
  AttributeFactory.Attributes['text'] = this

  constructor: (@el, @name) ->
    @templateValue =
      (child.nodeValue for child in @el.childNodes when child.nodeType == helpers.TEXT_NODE).join ''

    @children = _.toArray @el.children

    unless @textNode = @el.firstChild
      @el.appendChild @textNode = @el.ownerDocument.createTextNode ''
    else unless @textNode.nodeType is helpers.TEXT_NODE
      @textNode = @el.insertBefore @el.ownerDocument.createTextNode(''), @textNode

  set: (text) ->
    # content editable creates a new text node
    # which needs to be removed, otherwise the content is duplicated to both text nodes.
    # http://jsfiddle.net/xAMQa/1/
    @el.removeChild child while child = @el.firstChild

    @textNode.nodeValue = text
    @el.appendChild @textNode

    for child in @children
      @el.appendChild child


class Html extends Attribute
  AttributeFactory.Attributes['html'] = this

  constructor: (@el) ->
    @templateValue = ''
    @children = _.toArray @el.children

  set: (html) ->
    @el.removeChild child while child = @el.firstChild

    @el.innerHTML = html + @templateValue
    for child in @children
      @el.appendChild child


class Class extends Attribute
  AttributeFactory.Attributes['class'] = this

  constructor: (el) -> super el, 'class'
