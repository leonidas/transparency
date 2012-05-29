# Adapted from https://github.com/umdjs/umd
((root, factory) ->
  # AMD
  if define?.amd then define ['jquery'], factory

  # Node.js
  else if module?.exports
    module.exports = factory if $? then $ else fn: {}

  # Browser global
  else root.Transparency = factory if $? then $ else fn: {}

) this, ($) ->

  register = ($) ->
    $.fn.render = (models, directives, config) ->
      render context, models, directives, config for context in this
      this

  register $

  expando = 'transparency'
  data    = (element) ->
    # Expanding DOM element with a JS object is generally unsafe.
    # However, as references to expanded DOM elements are never lost, no memory leaks are introduced
    # http://perfectionkills.com/whats-wrong-with-extending-the-dom/
    element[expando] ||= {}

  nullLogger    = () ->
  consoleLogger = (messages...) -> console.log m for m in messages

  log    = null
  logger = (config) ->
    if config?.debug and console?
    then consoleLogger
    else nullLogger

  render = (context, models, directives, config) ->
    log = logger config
    log "Context:", context, "Models:", models, "Directives:", directives, "Config:", config
    return unless context
    models     ||= []
    directives ||= {}
    models       = [models] unless Array.isArray models

    # DOM manipulation is a lot faster when elements are detached.
    # Save the original position, so we can put the context back to it's place.
    sibling = context.nextSibling
    parent  = context.parentNode
    parent?.removeChild context

    # Make sure we have right amount of template instances available
    prepareContext context, models

    # Render each model to its template instance
    contextData = data context
    for model, index in models
      instance = contextData.instances[index]
      log "Model:", model, "Template instance for the model:", instance

      # Associate model with instance elements
      data(e).model = model for e in instance.elements

      renderValues      instance, model
      renderDirectives  instance, model, index, directives
      renderChildren    instance, model, directives, config

    # Finally, put the context element back to its original place in DOM
    if sibling
    then parent?.insertBefore context, sibling
    else parent?.appendChild context

    # Return the context to support jQuery-like chaining
    context

  prepareContext = (context, models) ->
    contextData                 = data context
    contextData.template      ||= (context.removeChild context.firstChild while context.firstChild)
    contextData.instanceCache ||= [] # Query-cached template instances are precious, save them for the future
    contextData.instances     ||= [] # Currently used template instances
    log "Original template", contextData.template

    # Get templates from the cache or clone new ones, if the cache is empty.
    while models.length > contextData.instances.length
      instance              = contextData.instanceCache.pop() || {}
      instance.queryCache ||= {}
      instance.template   ||= (cloneNode n for n in contextData.template)
      instance.elements   ||= elementNodes instance.template
      (context.appendChild n) for n in instance.template
      contextData.instances.push instance

    # Remove leftover templates from DOM and save them to the cache for later use.
    while models.length < contextData.instances.length
      contextData.instanceCache.push instance = contextData.instances.pop()
      (n.parentNode.removeChild n) for n in instance.template

  renderValues = (instance, model) ->
      for key, value of model when typeof model == 'object' and isPlainValue value
        for element in matchingElements instance, key, config

          if element.nodeName.toLowerCase() == 'input'
          then attr element, 'value', value
          else attr element, 'text',  value

  renderDirectives = (instance, model, index, directives) ->
    model = if typeof model == 'object' then model else value: model

    for key, attributes of directives
      unless typeof attributes == 'object'
        throw new Error "Directive syntax is directive[element][attribute] = function(params)"

      for element in matchingElements instance, key, config
        for attribute, directive of attributes when typeof directive == 'function'

          value = directive.call model, element: element, index: index, value: attr element, attribute
          attr element, attribute, value if value?

  renderChildren = (instance, model, directives, config) ->
    for key, value of model when typeof value == 'object' and not isDate value
      render element, value, directives[key], config for element in matchingElements instance, key, config

  setContent = (callback) ->
    (element, content) ->
      elementData = data element
      return if elementData.content == content

      elementData.content    = content
      elementData.children ||= (n for n in element.childNodes when n.nodeType == ELEMENT_NODE)

      (element.removeChild element.firstChild) while element.firstChild
      callback element, content
      (element.appendChild c) for c in elementData.children

  setHtml = setContent (element, html) -> element.innerHTML = html
  setText = setContent (element, text) -> element.appendChild element.ownerDocument.createTextNode text

  getText = (element) ->
    (child.nodeValue for child in element.childNodes when child.nodeType == TEXT_NODE).join ''

  attr = (element, attribute, value) ->
    value = value.toString() if value? and typeof value != 'string'

    # Save the original value, so it can be restored when the instance is reused
    elementData = data element
    elementData.originalAttributes ||= {}

    switch attribute
      when 'text'
        elementData.originalAttributes['text'] ||= getText element
        setText element, value if value?
      when 'html'
        elementData.originalAttributes['html'] ||= element.innerHTML
        setHtml element, value if value?
      when 'class'
        elementData.originalAttributes['class'] ||= element.className
        element.className = value if value?
      else
        elementData.originalAttributes[attribute] ||= element.getAttribute attribute
        element.setAttribute attribute, value if value?

    if value? then value else elementData.originalAttributes[attribute]

  elementNodes = (template) ->
    elements = []
    for e in template when e.nodeType == ELEMENT_NODE
      elements.push e
      elements.push child for child in e.getElementsByTagName '*'
    elements

  matchingElements = (instance, key) ->
    elements = instance.queryCache[key] ||= (e for e in instance.elements when config.matcher e, key)
    log "Matching elements for '#{key}':", elements
    elements

  elementMatcher = (element, key) ->
    element.id                        == key       ||
    element.className.split(' ').indexOf(key) > -1 ||
    element.name                      == key       ||
    element.getAttribute('data-bind') == key

  ELEMENT_NODE = 1
  TEXT_NODE    = 3

  # IE8 <= fails to clone detached nodes properly, shim with jQuery
  # jQuery.clone: https://github.com/jquery/jquery/blob/master/src/manipulation.js#L594
  # jQuery.support.html5Clone: https://github.com/jquery/jquery/blob/master/src/support.js#L83
  html5Clone = () -> document.createElement("nav").cloneNode(true).outerHTML != "<:nav></:nav>"
  cloneNode  =
    if not document? or html5Clone()
    then (node) -> node.cloneNode true
    else (node) -> $(node).clone()[0]

  Array.isArray  ?= (obj) -> $.isArray obj
  Array::indexOf ?= (obj) -> $.inArray obj, this

  # https://github.com/documentcloud/underscore/blob/master/underscore.js#L857
  isDate = (obj) -> Object.prototype.toString.call(obj) == '[object Date]'

  isPlainValue = (obj) -> isDate(obj) or typeof obj != 'object' and typeof obj != 'function'

  config =
    matcher: elementMatcher
    debug: false

  # Return module exports
  render: render
  register: register
  config: config

