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
    for e in instance.elements
      T.data(e).model = model

    renderValues      instance, model
    renderDirectives  instance, model, directives, index
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
  if typeof model == 'object'
    for key, value of model
      value = value.toISOString() if isDate value

      if typeof value != 'object' and typeof value != 'function'
        setText(element, value) for element in matchingElements(instance, key)

  # No models, just plain values
  else
    element = matchingElements(instance, 'listElement')[0] || instance.elements[0]
    setText(element, model) if element

renderDirectives = (instance, model, directives, index) ->
  for key, directiveFunction of directives when typeof directiveFunction == 'function'

    for element in matchingElements(instance, key)
      directive = directiveFunction.call(model, element, index)

      if not directive
        # Directive function returned no value, meaning
        # it most likely did element in-place manipulation
        # on element parameter
        continue

      directive = text: directive if typeof directive == 'string'

      setText element, directive.text
      setHtml element, directive.html
      for attr, value of directive when attr != 'html' and attr != 'text'
        # Save the original attribute values, so they can be restored when the instance is reused
        elementData = T.data element
        elementData.attributes       ||= {}
        elementData.attributes[attr] ||= element.getAttribute attr
        setAttribute element, attr, value

renderChildren = (instance, model, directives) ->
  for key, value of model when typeof value == 'object' and not isDate value
    T.render element, value, directives[key] for element in matchingElements(instance, key)

setContent = (callback) ->
  (e, content) ->
    eData = T.data(e)
    return if !e or !content? or eData.content == content
    eData.content    = content
    eData.children ||= (n for n in e.childNodes when n.nodeType == ELEMENT_NODE)

    (e.removeChild e.firstChild) while e.firstChild
    callback e, content
    (e.appendChild c) for c in eData.children

setHtml = setContent (e, html) -> e.innerHTML = html
setText = setContent (e, text) ->
  if e.nodeName.toLowerCase() == 'input'
    setAttribute e, 'value', text
  else
    e.appendChild e.ownerDocument.createTextNode text

setAttribute = (element, attr, value) ->
  if attr == 'class'
    element.className = value
  else if element[attr]
    element[attr] = value
  else
    element.setAttribute attr, value

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
  element.id                        == key               ||
  element.className.split(' ').indexOf(key) > -1         ||
  element.name                      == key               ||
  element.getAttribute('data-bind') == key

ELEMENT_NODE = 1

# Browser compatibility shims

# IE8 <= fails to clone detached nodes properly. See jQuery.clone for the details
# jQuery.clone: https://github.com/jquery/jquery/blob/master/src/manipulation.js#L594
# jQuery.support.html5Clone: https://github.com/jquery/jquery/blob/master/src/support.js#L83
cloneNode = if document.createElement("nav").cloneNode(true).outerHTML != "<:nav></:nav>"
    (node) -> node.cloneNode true
  else
    (node) ->
      if node.nodeType == ELEMENT_NODE && node.nodeName.toLowerCase() != "option"
        div = document.createElement "div"
        div.innerHTML = node.outerHTML
        # In IE expando property == attribute (IE8 and below) and attributes are copied from the original element to the cloned one.
        # Remove the expando attribute from the copy, otherwise the original and the cloned element would share the Transparency data object
        # http://msdn.microsoft.com/en-us/library/ie/gg622931(v=vs.85).aspx
        # http://webreflection.blogspot.com/2009/04/divexpando-null-or-divremoveattributeex.html
        div.firstChild?.removeAttribute expando
        div.firstChild
      else
        node.cloneNode true

# http://stackoverflow.com/questions/1744310/how-to-fix-array-indexof-in-javascript-for-ie-browsers
Array::indexOf ?= (obj) ->
  index = -1
  for x, i in this when x == obj
    index = i
    break
  index

# http://perfectionkills.com/instanceof-considered-harmful-or-how-to-write-a-robust-isarray/
Array.isArray ?= (obj) ->
  Object.prototype.toString.call(obj) == '[object Array]'

# https://github.com/documentcloud/underscore/blob/master/underscore.js#L857
isDate = (obj) ->
  Object.prototype.toString.call(obj) == '[object Date]'

# https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Date/toISOString
pad = (n) ->
  if n < 10 then "0#{n}" else n.toString()

Date::toISOString ?= () ->
  "#{@getUTCFullYear()}-#{pad @getUTCMonth() + 1}-#{pad @getUTCDate()}" +
  "T#{pad @getUTCHours()}:#{pad @getUTCMinutes()}:#{pad @getUTCSeconds()}.#{String((@getUTCMilliseconds() / 1000).toFixed 3).slice 2, 5}Z"


