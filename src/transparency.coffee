# Adapted from https://github.com/umdjs/umd
((root, factory) ->
  # AMD
  if define?.amd then define factory

  # Node.js
  else if module?.exports
    module.exports = factory()

  # Browser global
  else root.Transparency = factory()

) this, () ->

  register = ($) ->
    $.fn.render = (models, directives, config) ->
      render context, models, directives, config for context in this
      this

  if @jQuery? or @Zepto?
    $ = @jQuery or @Zepto
    register $

  expando = 'transparency'
  data    = (element) ->
    # Expanding DOM element with a JS object is generally unsafe.
    # However, as references to expanded DOM elements are never lost, no memory leaks are introduced
    # http://perfectionkills.com/whats-wrong-with-extending-the-dom/
    element[expando] ||= {}

  nullLogger    = () ->
  consoleLogger = (messages...) -> console.log m for m in messages
  log           = nullLogger

  render = (context, models, directives, config) ->
    log = if config?.debug and console? then consoleLogger else nullLogger
    log "Context:", context, "Models:", models, "Directives:", directives, "Config:", config
    return unless context

    models     ||= []
    directives ||= {}
    models       = [models] unless Array.isArray models

    # DOM manipulation is a lot faster when elements are detached.
    # Save the original position, so we can put the context back to it's place.
    parent = context.parentNode
    if parent
      sibling = context.nextSibling
      parent.removeChild context

    # Make sure we have right amount of template instances available
    prepareContext context, models

    # Render each model to its template instance
    contextData = data context
    for model, index in models
      children  = []
      instance  = contextData.instances[index]
      log "Model:", model, "Template instance for the model:", instance

      # Associate model with instance elements
      data(e).model = model for e in instance.elements

      # Render values
      if isDomElement(model) and element = instance.elements[0]
        empty(element).appendChild model

      else if typeof model == 'object'
        for own key, value of model when value?

          if isPlainValue value
            for element in matchingElements instance, key

              nodeName = element.nodeName.toLowerCase()
              if nodeName == 'input'
                attr element, 'value', value
              else if nodeName == 'select'
                attr element, 'selected', value
              else attr element, 'text',  value

          else if typeof value == 'object'
            children.push key

      # Render directives
      renderDirectives instance, model, index, directives

      # Render children
      for key in children
        for element in matchingElements instance, key
          render element, model[key], directives[key], config

    # Finally, put the context element back to its original place in DOM
    if parent
      if sibling
      then parent.insertBefore context, sibling
      else parent.appendChild context

    # Return the context to support jQuery-like chaining
    context

  prepareContext = (context, models) ->
    contextData = data context

    # Initialize context
    unless contextData.template
      contextData.template      = cloneNode context
      contextData.instanceCache = [] # Query-cached template instances are precious, save them for the future
      contextData.instances     = [new Instance(context)] # Currently used template instances
    log "Template", contextData.template

    # Get templates from the cache or clone new ones, if the cache is empty.
    while models.length > contextData.instances.length
      instance = contextData.instanceCache.pop() || new Instance(cloneNode contextData.template)
      (context.appendChild n for n in instance.childNodes)
      contextData.instances.push instance

    # Remove leftover templates from DOM and save them to the cache for later use.
    while models.length < contextData.instances.length
      contextData.instanceCache.push instance = contextData.instances.pop()
      (n.parentNode.removeChild n) for n in instance.childNodes

  class Instance
    constructor: (@template) ->
      @queryCache = {}
      @elements   = []
      @childNodes = []
      getElementsAndChildNodes @template, @elements, @childNodes

  getElementsAndChildNodes = (template, elements, childNodes) ->
    child = template.firstChild
    while child
      childNodes?.push child

      if child.nodeType == ELEMENT_NODE
        elements.push child
        getElementsAndChildNodes child, elements

      child = child.nextSibling

  renderDirectives = (instance, model, index, directives) ->
    return unless directives
    model = if typeof model == 'object' then model else value: model

    for own key, attributes of directives
      unless typeof attributes == 'object'
        throw new Error "Directive syntax is directive[element][attribute] = function(params)"

      for element in matchingElements instance, key
        for attribute, directive of attributes when typeof directive == 'function'

          value = directive.call model, element: element, index: index, value: attr element, attribute
          attr element, attribute, value

  setHtml = (element, html) ->
    elementData = data element
    return if elementData.html == html

    elementData.html       = html
    elementData.children ||= (n for n in element.childNodes when n.nodeType == ELEMENT_NODE)

    empty element
    element.innerHTML = html
    element.appendChild child for child in elementData.children

  setText = (element, text) ->
    elementData = data element
    return if !text? or elementData.text == text

    elementData.text = text
    textNode         = element.firstChild

    if !textNode
      element.appendChild element.ownerDocument.createTextNode text

    else if textNode.nodeType != TEXT_NODE
      element.insertBefore element.ownerDocument.createTextNode(text), textNode

    else
      textNode.nodeValue = text

  getText = (element) ->
    (child.nodeValue for child in element.childNodes when child.nodeType == TEXT_NODE).join ''

  setSelected = (element, value) ->
    childElements = []
    getElementsAndChildNodes element, childElements
    for child in childElements
      if child.nodeName.toLowerCase() == 'option'
        if child.value == value
          child.selected = true
        else
          child.selected = false

  attr = (element, attribute, value) ->
    value = value.toString() if value? and typeof value != 'string'

    # Save the original value, so it can be restored when the instance is reused
    elementData = data element
    elementData.originalAttributes ||= {}

    switch attribute

      when 'text'
        elementData.originalAttributes['text'] ||= getText element
        setText(element, value) if value?

      when 'html'
        elementData.originalAttributes['html'] ||= element.innerHTML
        setHtml(element, value) if value?

      when 'class'
        elementData.originalAttributes['class'] ||= element.className
        element.className = value if value?

      when 'selected'
        setSelected(element, value) if value?

      else
        elementData.originalAttributes[attribute] ||= element.getAttribute attribute
        element.setAttribute(attribute, value) if value?

    if value? then value else elementData.originalAttributes[attribute]

  matchingElements = (instance, key) ->
    elements = instance.queryCache[key] ||= (e for e in instance.elements when exports.matcher e, key)
    log "Matching elements for '#{key}':", elements
    elements

  matcher = (element, key) ->
    element.id                        == key       ||
    element.className.split(' ').indexOf(key) > -1 ||
    element.name                      == key       ||
    element.getAttribute('data-bind') == key

  empty = (element) ->
    element.removeChild child while child = element.firstChild
    element

  ELEMENT_NODE = 1
  TEXT_NODE    = 3

  # IE8 <= fails to clone detached nodes properly, shim with jQuery
  # jQuery.clone: https://github.com/jquery/jquery/blob/master/src/manipulation.js#L594
  # jQuery.support.html5Clone: https://github.com/jquery/jquery/blob/master/src/support.js#L83
  html5Clone = () -> document.createElement("nav").cloneNode(true).outerHTML != "<:nav></:nav>"
  cloneNode  =
    if not document? or html5Clone()
      (node) -> node.cloneNode true
    else
      (node) ->
        clone = $(node).clone()[0]
        if clone.nodeType == ELEMENT_NODE
          clone.removeAttribute expando
          (element.removeAttribute expando) for element in clone.getElementsByTagName '*'
        clone

  Array.isArray  ?= (obj) -> $.isArray obj
  Array::indexOf ?= (obj) -> $.inArray obj, this

  # https://github.com/documentcloud/underscore/blob/master/underscore.js#L857
  isDate = (obj) -> Object.prototype.toString.call(obj) == '[object Date]'

  isDomElement = (obj) -> obj?.nodeType == ELEMENT_NODE

  isPlainValue = (obj) -> isDate(obj) or typeof obj != 'object' and typeof obj != 'function'

  # Return module exports
  exports =
    render:   render
    register: register
    matcher:  matcher
