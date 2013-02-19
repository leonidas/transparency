class AttributeFactory
  @Attributes = {}

  createAttribute: (element, name, value) ->
    Klass = AttributeFactory.Attributes[name] or
      if isBoolean value then BooleanAttribute else Attribute
    new Klass(element, name)

class Attribute
  constructor: (@el, @name) ->
    @templateValue = @el.getAttribute(@name) || ''

  set: (value) ->
    @el[@name] = value
    @el.setAttribute @name, value.toString()

class BooleanAttribute extends Attribute
  constructor: (@el, @name) ->
    @templateValue = @el.getAttribute(@name) || false

  set: (value) ->
    @el[@name] = value
    if value
    then @el.setAttribute @name, value
    else @el.removeAttribute @name

class Text extends Attribute
  AttributeFactory.Attributes.text = this

  constructor: (@el, @name) ->
    @templateValue =
      (child.nodeValue for child in getChildNodes @el when child.nodeType == TEXT_NODE).join ''

    unless @textNode = @el.firstChild
      @el.appendChild @textNode = @el.ownerDocument.createTextNode ''

    else unless @textNode.nodeType is TEXT_NODE
      @textNode = @el.insertBefore @el.ownerDocument.createTextNode(''), @textNode

  set: (text) -> @textNode.nodeValue = text

class Html extends Attribute
  AttributeFactory.Attributes.html = this

  constructor: (el) ->
    super el, 'innerHTML'
    @childNodes = getChildNodes @el

  set: (html) ->
    @el.innerHTML = html
    for child in @childNodes
      @el.appendChild child

class Class extends Attribute
  AttributeFactory.Attributes.class = this

  constructor: (el) -> super el, 'class'

