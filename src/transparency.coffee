jQuery?.fn.render = (models, directives, config) ->
  T.render context, models, directives, config for context in this
  this

# Export for browsers
@Transparency = Transparency = {}

# Export for Node.js
module?.exports = Transparency

# For internal use
T = Transparency

expando = 'transparency'
T.data  = (element) ->
  # Expanding DOM element with a JS object is generally unsafe.
  # However, as references to expanded DOM elements are never lost, no memory leaks are introduced
  # http://perfectionkills.com/whats-wrong-with-extending-the-dom/
  element[expando] ||= {}

debug     = null
debugMode = (debug) ->
  if debug and console?
    (messages...) -> console.log m for m in messages
  else
    () ->

T.render = (context, models, directives, config) ->
  debug = debugMode config?.debug
  debug "Context:", context, "Models:", models, "Directives:", directives, "Config:", config
  return unless context
  models     ||= []
  directives ||= {}
  models       = [models] unless Array.isArray models

  # DOM manipulation is a lot faster when elements are detached. Save the original position, so we can put the context back to it's place.
  sibling = context.nextSibling
  parent  = context.parentNode
  parent?.removeChild context

  # Make sure we have right amount of template instances available
  prepareContext context, models

  # Render each model to its template instance
  contextData = T.data context
  for model, index in models
    instance = contextData.instances[index]
    debug "Model:", model, "Template instance for the model:", instance

    # Associate model with instance elements
    T.data(e).model = model for e in instance.elements

    renderValues      instance, model
    renderDirectives  instance, model, index, directives
    renderChildren    instance, model, directives

  # Finally, put the context element back to its original place in DOM
  if sibling then parent?.insertBefore(context, sibling) else parent?.appendChild context
  context

prepareContext = (context, models) ->
  contextData                 = T.data context
  contextData.template      ||= (context.removeChild context.firstChild while context.firstChild)
  contextData.instanceCache ||= [] # Query-cached template instances are precious, so save them for the future
  contextData.instances     ||= [] # Currently used template instances
  debug "Original template", contextData.template

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

  # Restore the original attribute values
  for instance in contextData.instances
    for e in instance.elements
      (setAttribute e, attr, value) for attr, value of T.data(e).attributes

renderValues = (instance, model) ->
    for key, value of model when typeof model == 'object'
      value = value.toISOString() if isDate value

      if typeof value != 'object' and typeof value != 'function'
        setText(element, value) for element in matchingElements(instance, key)

renderDirectives = (instance, model, index, directives) ->
  for key, attributes of directives # when typeof when typeof element == object
    #throw new Error "Transparency: Directives should be two-dimensional objects, e.g., directive[element][attribute] = function(){}"

    for element in matchingElements instance, key
      for attribute, directive of attributes when typeof directive == 'function'

        value = directive.call (if typeof model == 'object' then model else value: model), element, index
        setAttribute element, attribute, value if value

renderChildren = (instance, model, directives) ->
  for key, value of model when typeof value == 'object' and not isDate value
    T.render element, value, directives[key] for element in matchingElements(instance, key)

setContent = (callback) ->
  (element, content) ->
    elementData = T.data element
    return if !element or !content? or elementData.content == content
    elementData.content    = content
    elementData.children ||= (n for n in element.childNodes when n.nodeType == ELEMENT_NODE)

    (element.removeChild element.firstChild) while element.firstChild
    callback element, content
    (element.appendChild c) for c in elementData.children

setHtml = setContent (element, html) -> element.innerHTML = html
setText = setContent (element, text) ->
  if element.nodeName.toLowerCase() == 'input'
    setAttribute element, 'value', text
  else
    element.appendChild element.ownerDocument.createTextNode text

getText = (element) ->
  "todo"

setAttribute = (element, attribute, value) ->
  # Save the original value, so it can be restored before the instance is reused
  elementData = T.data element
  elementData.attributes ||= {}
  switch attribute
    when 'text'
      elementData.attributes['text'] ||= getText element
      setText element, value
    when 'html'
      elementData.attributes['html'] ||= element.innerHTML
      setHtml element, value
    when 'class'
      elementData.attributes['class'] ||= element.className
      element.className = value
    else
      elementData.attributes[attribute] ||= element.getAttribute attribute
      element.setAttribute attribute, value

elementNodes = (template) ->
  elements = []
  for e in template when e.nodeType == ELEMENT_NODE
    elements.push e
    for child in e.getElementsByTagName '*'
      elements.push child
  elements

matchingElements = (instance, key) ->
  elements = instance.queryCache[key] ||= (e for e in instance.elements when elementMatcher e, key)
  debug "Matching elements for '#{key}':", elements
  elements

elementMatcher = (element, key) ->
  element.id                        == key       ||
  element.className.split(' ').indexOf(key) > -1 ||
  element.name                      == key       ||
  element.getAttribute('data-bind') == key

ELEMENT_NODE = 1

# IE8 <= fails to clone detached nodes properly, shim with jQuery
# jQuery.clone: https://github.com/jquery/jquery/blob/master/src/manipulation.js#L594
# jQuery.support.html5Clone: https://github.com/jquery/jquery/blob/master/src/support.js#L83
html5Clone = () -> document.createElement("nav").cloneNode( true ).outerHTML != "<:nav></:nav>"
cloneNode  = if not html5Clone() then (node) -> jQuery(node).clone()[0] else (node) -> node.cloneNode true

Array.isArray  ?= (obj) -> jQuery.isArray obj
Array::indexOf ?= (obj) -> jQuery.inArray obj, this

# https://github.com/documentcloud/underscore/blob/master/underscore.js#L857
isDate = (obj) -> Object.prototype.toString.call(obj) == '[object Date]'

# https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Date/toISOString
pad = (n) -> if n < 10 then "0#{n}" else n.toString()

Date::toISOString ?= () ->
  "#{@getUTCFullYear()}-#{pad @getUTCMonth() + 1}-#{pad @getUTCDate()}" +
  "T#{pad @getUTCHours()}:#{pad @getUTCMinutes()}:#{pad @getUTCSeconds()}" +
  ".#{String((@getUTCMilliseconds() / 1000).toFixed 3).slice 2, 5}Z"
