jQuery?.fn.render = (models, directives) ->
  Transparency.render this.get(), models, directives
  this

@Transparency    = Transparency = {}
module?.exports  = Transparency

Transparency.safeHtml = (str) -> ({html: str, safeHtml: true})

Transparency.render = (contexts, models, directives) ->
  # NodeList is a live array. Clone it to Array.
  contexts     = if contexts.length? then (c for c in contexts) else [contexts]
  models       = [models] unless models instanceof Array
  directives ||= {}

  for context in contexts
    # DOM manipulation is a lot faster when elements are detached. Save the original position, so we can put the context back to it's place.
    sibling = context.nextSibling
    parent  = context.parentNode
    parent?.removeChild context

    # Make sure we have right amount of template instances available
    prepareContext context, models

    # Render each model to its template instance
    for model, i in models
      instance = context.transparency.instances[i]

      # Associate model with instance elements
      for e in instance.elements
        e.transparency     ||= {}
        e.transparency.model = model

      renderValues      instance, model
      renderDirectives  instance, model, directives
      renderChildren    instance, model, directives, context

    # Finally, put the context element back to it's original place in DOM
    if sibling then parent?.insertBefore(context, sibling) else parent?.appendChild context
  return contexts

prepareContext = (context, models) ->
  # Extend context element with transparency hash to store the template elements and cached instances
  context.transparency                ||= {}
  context.transparency.template       ||= (context.removeChild context.firstChild while context.firstChild)
  context.transparency.templateCache  ||= [] # Query-cached templates are precious, so save them for the future
  context.transparency.instances      ||= [] # Currently used template instances

  # Get templates from the cache or clone new ones, if the cache is empty.
  while models.length > context.transparency.instances.length
    template = context.transparency.templateCache.pop() || (n.cloneNode true for n in context.transparency.template)
    (context.appendChild n) for n in template
    context.transparency.instances.push
      queryCache: {}
      template:   template
      elements:   elementNodes template

  # Remove leftover templates from DOM and save them to the cache for later use.
  while models.length < context.transparency.instances.length
    context.transparency.templateCache.push ((context.removeChild n) for n in context.transparency.instances.pop())

renderValues = (instance, model) ->
  if typeof model == 'object'
    for key, value of model when typeof value != 'object'
      setText(element, value) for element in matchingElements(instance, key)
  else
    element = matchingElements(instance, 'listElement')[0] || instance.elements[0]
    setText(element, model) if element

renderDirectives = (instance, model, directives) ->
  for key, directive of directives when typeof directive == 'function'
    [key, attr] = key.split('@')

    for e in matchingElements(instance, key)
      result = directive.call(model, e)
      if attr then e.setAttribute(attr, result) else setText e, result

renderChildren = (instance, model, directives, context) ->
  for key, value of model when typeof value == 'object'
    Transparency.render element, value, directives[key] for element in matchingElements(instance, key)

setText = (e, text) ->
  return if e?.transparency?.text == text
  e.transparency    ||= {}
  e.transparency.text = text
  children            = filter ((n) -> n.nodeType == ELEMENT_NODE), e.childNodes

  (e.removeChild e.firstChild) while e.firstChild
  if text.safeHtml then e.innerHTML = text.html else e.appendChild e.ownerDocument.createTextNode text
  (e.appendChild c) for c in children

matchingElements = (instance, key) ->
  instance.queryCache[key] ||= (e for e in instance.elements when elementMatcher e, key)

elementNodes = (template) ->
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

# Browser compatibility
filter ?= (p, xs) -> (x for x in xs when p x)
Array::filter  ?= (p) -> (x for x in this when p x)
Array::indexOf ?= (s) ->
  index = -1
  for x, i in this when x == s
    index = i
    break;
  index
