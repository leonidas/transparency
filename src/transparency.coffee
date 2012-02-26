jQuery?.fn.render = (objects, directives) ->
  Transparency.render this.get(), objects, directives
  this

@Transparency    = Transparency = {}
module?.exports  = Transparency

indexCache ?= {} # Indexes of matching elements. Shared between for all template instances
contextId  ?= 0  # Global IDs for contexts. Part of keys for indexCache

Transparency.safeHtml = (str) -> ({html: str, safeHtml: true})

Transparency.render = (contexts, objects, directives) ->
  # NodeList is a live array. Clone it to Array.
  contexts     = if contexts.length? then (c for c in contexts) else [contexts]
  isArray      = objects instanceof Array
  objects      = [objects] unless objects instanceof Array
  directives ||= {}

  for context in contexts
    # DOM manipulation is a lot faster when elements are detached. Save the original position, so we can put the context back to it's place.
    sibling = context.nextSibling
    parent  = context.parentNode
    parent?.removeChild context

    # Make sure we have right amount of template instances available
    prepareContext context, objects

    # Render each object to its template instance
    for object, i in objects
      instance = context.transparency.instances[i]

      # Associate model object with instance element
      for n in instance.template when isArray and n.nodeType == ELEMENT_NODE
        n.transparency     ||= {}
        n.transparency.model = object

      renderValues      instance, object
      renderDirectives  instance, object, directives
      renderChildren    instance, object, directives, context

    # Finally, put the context element back to it's original place in DOM
    if sibling then parent?.insertBefore(context, sibling) else parent?.appendChild context
  return contexts

prepareContext = (context, objects) ->
  # Extend context element with transparency hash to store the template elements and cached instances
  context.transparency                ||= {}
  context.transparency.template       ||= (context.removeChild context.firstChild while context.firstChild)
  context.transparency.templateCache  ||= [] # Query-cached templates are precious, so save them for the future
  context.transparency.instances      ||= [] # Currently used template instances
  context.transparency.indexCache     ||= {} # Indexes of matching elements. Shared cache for all instances
  context.transparency.id             ||= contextId++
  indexCache[context.transparency.id] ||= {}

  # Get templates from the cache or clone new ones, if the cache is empty.
  while objects.length > context.transparency.instances.length
    template = context.transparency.templateCache.pop() || (n.cloneNode true for n in context.transparency.template)
    (context.appendChild n) for n in template
    context.transparency.instances.push
      indexCache: indexCache[context.transparency.id]
      queryCache: {}
      template:   template
      elements:   templateElements template

  # Remove leftover templates from DOM and save them to the cache for later use.
  while objects.length < context.transparency.instances.length
    context.transparency.templateCache.push ((context.removeChild n) for n in context.transparency.instances.pop())

renderValues = (instance, object) ->
  if typeof object == 'object'
    for k, v of object when typeof v != 'object'
      setText(e, v) for e in matchingElements(instance, k)
  else
    element = matchingElements(instance, 'listElement')[0] || instance.elements[0]
    setText(element, object) if element

renderDirectives = (instance, object, directives) ->
  for key, directive of directives when typeof directive == 'function'
    [key, attr] = key.split('@')

    for e in matchingElements(instance, key)
      result = directive.call(object, e)
      if attr then e.setAttribute(attr, result) else setText e, result

renderChildren = (instance, object, directives, context) ->
  for key, value of object when typeof value == 'object'
    for e, i in matchingElements(instance, key)
      e.transparency    ||= {}
      e.transparency.id   = "#{context.transparency.id}-#{key}-#{i}"
      Transparency.render e, value, directives[key]

setText = (e, text) ->
  return if e?.transparency?.text == text
  e.transparency    ||= {}
  e.transparency.text = text
  children            = filter ((n) -> n.nodeType == ELEMENT_NODE), e.childNodes

  (e.removeChild e.firstChild) while e.firstChild

  if text.safeHtml then e.innerHTML = text.html else e.appendChild e.ownerDocument.createTextNode text

  (e.appendChild c) for c in children

matchingElements = (instance, key) ->
  # Use instance cache
  if instance.queryCache[key]
    instance.queryCache[key]

  # Use index cache and build instance cache
  else if instance.indexCache[key]
    instance.queryCache[key] = for i in instance.indexCache[key]
      instance.elements[i]

  # Build caches
  else
    instance.indexCache[key] = indexCache = []
    instance.queryCache[key] = for e, i in instance.elements when elementMatcher(e, key)
      indexCache.push i
      e

templateElements = (template) ->
  elements = []
  for e in template when e.nodeType == ELEMENT_NODE
    elements.push e
    (elements.push child) for child in e.getElementsByTagName '*'
  elements

elementMatcher = (element, key) ->
  element.nodeType                  == ELEMENT_NODE      &&
  element.className.split(' ').indexOf(key) > -1         ||
  element.id                        == key               ||
  element.tagName.toLowerCase()     == key.toLowerCase() ||
  element.getAttribute('data-bind') == key

ELEMENT_NODE = 1
filter      ?= (p, xs) -> (x for x in xs when p x)
