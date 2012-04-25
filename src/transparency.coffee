jQuery?.fn.render = (models, directives) ->
  T.render this.get(), models, directives
  this

# Export for browsers
@Transparency = Transparency = {}

# Export for Node.js
module?.exports = Transparency

# For internal use
T = Transparency

# Simple jQuery.data implementation, as extending DOM elements directly with expando objects leads to bugs and memory leaks on IE
# http://perfectionkills.com/whats-wrong-with-extending-the-dom/
expando = "transparency-" + Math.random()
uid     = 0
cache   = {}

T.data = (element) ->
  id  = element[expando] ?= uid++
  val = cache[id] ||= {}

T.render = (contexts, models, directives) ->
  return unless contexts
  models     ||= []
  directives ||= {}
  # Context may be a NodeList. Clone it to Array
  contexts     = if contexts.length? and contexts[0] then (c for c in contexts) else [contexts]
  models       = [models] unless Array.isArray models

  for context in contexts
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

      # Associate model with instance elements
      for e in instance.elements
        T.data(e).model = model

      renderValues      instance, model
      renderDirectives  instance, model, directives, index
      renderChildren    instance, model, directives

    # Finally, put the context element back to it's original place in DOM
    if sibling then parent?.insertBefore(context, sibling) else parent?.appendChild context
  return contexts

prepareContext = (context, models) ->
  contextData                 = T.data context
  contextData.template      ||= (context.removeChild context.firstChild while context.firstChild)
  contextData.instanceCache ||= [] # Query-cached template instances are precious, so save them for the future
  contextData.instances     ||= [] # Currently used template instances

  # Get templates from the cache or clone new ones, if the cache is empty.
  while models.length > contextData.instances.length
    instance              = contextData.instanceCache.pop() || {}
    instance.queryCache ||= {}
    instance.template   ||= (n.cloneNode true for n in contextData.template)
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
      (e.setAttribute attr, value) for attr, value of T.data(e).attributes

renderValues = (instance, model) ->
  if typeof model == 'object'
    for key, value of model when (typeof value != 'object' && typeof value != 'function')
      setText(element, value) for element in matchingElements(instance, key)
  else
    element = matchingElements(instance, 'listElement')[0] || instance.elements[0]
    setText(element, model) if element

renderDirectives = (instance, model, directives, index) ->
  for key, directiveFunction of directives when typeof directiveFunction == 'function'

    for element in matchingElements(instance, key)
      directive = directiveFunction.call(model, element, index)
      directive = text: directive if typeof directive == 'string'

      setText element, directive.text
      setHtml element, directive.html
      for attr, value of directive when attr != 'html' and attr != 'text'
        # Save the original attribute values, so they can be restored when the instance is reused
        elementData = T.data element
        elementData.attributes       ||= {}
        elementData.attributes[attr] ||= element.getAttribute attr
        element.setAttribute attr, value

renderChildren = (instance, model, directives) ->
  for key, value of model when typeof value == 'object'
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
    e.setAttribute 'value', text
  else
    e.appendChild e.ownerDocument.createTextNode text

matchingElements = (instance, key) ->
  instance.queryCache[key] ||= (e for e in instance.elements when elementMatcher e, key)

elementNodes = (template) ->
  elements = []
  for e in template when e.nodeType == ELEMENT_NODE
    elements.push e
    for child in e.getElementsByTagName '*'
      elements.push child
  elements

elementMatcher = (element, key) ->
  element.id                        == key               ||
  element.className.split(' ').indexOf(key) > -1         ||
  element.name                      == key               ||
  element.getAttribute('data-bind') == key

ELEMENT_NODE = 1

# Browser compatibility
Array::indexOf ?= (s) ->
  index = -1
  for x, i in this when x == s
    index = i
    break
  index

# http://perfectionkills.com/instanceof-considered-harmful-or-how-to-write-a-robust-isarray/
Array.isArray ?= (ob) ->
  Object.prototype.toString.call(ob) == '[object Array]'

