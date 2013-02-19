ElementFactory =
  Elements: {}

  createElement: (el) ->
    Klass = ElementFactory.Elements[el.nodeName.toLowerCase()] || Element
    new Klass(el)


class Element
  constructor: (@el) ->
    @attributes         = {}
    @childNodes         = getChildNodes @el
    @nodeName           = @el.nodeName.toLowerCase()
    @classNames         = @el.className.split ' '
    @originalAttributes = {}

  empty: chainable ->
    @el.removeChild child while child = @el.firstChild

  reset: ->
    for name, attribute of @attributes
      attribute.set attribute.templateValue

  render: (value) -> @attr 'text', value

  attr: (name, value) ->
    attribute = @attributes[name] ||= AttributeFactory.createAttribute @el, name, value
    attribute.set value

  renderDirectives: (model, index, attributes) ->
    for own name, directive of attributes when typeof directive == 'function'
      value = directive.call model,
        element: @el
        index:   index
        value:   @attributes[name]?.templateValue || ''

      @attr(name, value) if value?


class VoidElement extends Element

  # From http://www.w3.org/TR/html-markup/syntax.html: void elements in HTML
  VOID_ELEMENTS = ['area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img',
    'input', 'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr']

  for nodeName in VOID_ELEMENTS
    ElementFactory.Elements[nodeName] = this

  attr: (name, value) -> super name, value unless name in ['text', 'html']


class Input extends VoidElement
  ElementFactory.Elements['input'] = this

  render: (value) -> @attr 'value', value


class Select extends Element
  ElementFactory.Elements['select'] = this

  render: (value) ->
    value = value.toString()
    for child in getElements @el when child.nodeName == 'option'
      child.el.selected = child.el.value == value

