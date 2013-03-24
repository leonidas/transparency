_                = require '../lib/lodash.js'
helpers          = require './helpers'
AttributeFactory = require './attributeFactory'


module.exports = ElementFactory =
  Elements: input: {}

  createElement: (el) ->
    if 'input' == name = el.nodeName.toLowerCase()
      El = ElementFactory.Elements[name][el.type.toLowerCase()] || Input
    else
      El = ElementFactory.Elements[name] || Element

    new El(el)


class Element
  constructor: (@el) ->
    @attributes         = {}
    @childNodes         = _.toArray @el.childNodes
    @nodeName           = @el.nodeName.toLowerCase()
    @classNames         = @el.className.split ' '
    @originalAttributes = {}

  empty: ->
    @el.removeChild child while child = @el.firstChild
    this

  reset: ->
    for name, attribute of @attributes
      attribute.set attribute.templateValue

  render: (value) -> @attr 'text', value

  attr: (name, value) ->
    attribute = @attributes[name] ||= AttributeFactory.createAttribute @el, name, value
    attribute.set value if value?
    attribute

  renderDirectives: (model, index, attributes) ->
    for own name, directive of attributes when typeof directive == 'function'
      value = directive.call model,
        element: @el
        index:   index
        value:   @attr(name).templateValue

      @attr(name, value) if value?


class Select extends Element
  ElementFactory.Elements['select'] = this

  constructor: (el) ->
    super el
    @elements = helpers.getElements el

  render: (value) ->
    value = value.toString()
    for option in @elements when option.nodeName == 'option'
      option.attr 'selected', option.el.value == value


class VoidElement extends Element

  # From http://www.w3.org/TR/html-markup/syntax.html: void elements in HTML
  VOID_ELEMENTS = ['area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img',
    'input', 'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr']

  for nodeName in VOID_ELEMENTS
    ElementFactory.Elements[nodeName] = this

  attr: (name, value) -> super name, value unless name in ['text', 'html']


class Input extends VoidElement
  render: (value) -> @attr 'value', value


class TextArea extends Input
  ElementFactory.Elements['textarea'] = this


class Checkbox extends Input
  ElementFactory.Elements['input']['checkbox'] = this

  render: (value) -> @attr 'checked', Boolean(value)


class Radio extends Checkbox
  ElementFactory.Elements['input']['radio'] = this
