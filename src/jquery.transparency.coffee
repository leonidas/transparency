jQuery.fn.render = (objects, directives) ->
  Transparency.render this.get(), objects, directives
  this

Transparency = @Transparency = {}

Transparency.render = (contexts, objects, directives) ->
  # NodeList is a live array, which sucks hard. Clone it to Array.
  contexts     = if contexts.length? then Array.prototype.slice.call(contexts, 0) else [contexts]
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

      # Attach the template instance elements to DocumentFragment for rendering
      (context.transparency.fragment.appendChild n) for n in context.transparency.instances[i]

      renderValues      context.transparency.fragment, object
      renderDirectives  context.transparency.fragment, object, directives
      renderChildren    context.transparency.fragment, object, directives

      # Attach the template instance elements back to the context
      context.appendChild n while n = context.transparency.fragment.firstChild

    # Finally, put the context element back to it's original place in DOM
    if sibling then parent?.insertBefore(context, sibling) else parent?.appendChild context
  return contexts

prepareContext = (context, objects) ->
  # Extend context element with transparency hash to store the template elements and cached instances
  context.transparency               ||= {}
  context.transparency.template      ||= (context.removeChild context.firstChild while context.firstChild)
  context.transparency.templateCache ||= [] # Query-cached templates are precious, so save them for the future
  context.transparency.instances     ||= [] # Currently used template instances
  context.transparency.fragment      ||= context.ownerDocument.createElement('div')

  # Get templates from the cache or clone new ones, if the cache is empty.
  while objects.length > context.transparency.instances.length
    template = context.transparency.templateCache.pop() || (map ((n) -> n.cloneNode true), context.transparency.template)
    context.transparency.instances.push template

  # Remove leftover templates from DOM and save them to the cache for later use.
  while objects.length < context.transparency.instances.length
    context.transparency.templateCache.push ((context.removeChild n) for n in context.transparency.instances.pop())

renderValues = (template, object) ->
  if typeof object == 'object'
    for k, v of object when typeof v != 'object'
      setText(e, v) for e in matchingElements(template, k)
  else
    element = matchingElements(template, 'listElement')[0] || jQuery(template).children()[0]
    setText(element, object) if element

renderDirectives = (template, object, directives) ->
  for key, directive of directives when typeof directive == 'function'
    [key, attr] = key.split('@')

    for e in matchingElements(template, key)
      v = directive.call(object, e)
      if attr then e.setAttribute(attr, v) else setText e, v

renderChildren = (template, object, directives) ->
  (Transparency.render matchingElements(template, k), v, directives[k]) for k, v of object when typeof v == 'object'

setText = (e, text) ->
  return if e?.transparency?.text == text
  e.transparency    ||= {}
  e.transparency.text = text
  textNode            = e.ownerDocument.createTextNode text
  children            = filter ((n) -> n.nodeType == ELEMENT_NODE), e.childNodes

  (e.removeChild e.firstChild) while e.firstChild
  e.appendChild textNode
  (e.appendChild c) for c in children

matchingElements = (template, key) ->
  return [] unless firstChild = template.firstChild
  firstChild.transparency                 ||= {}
  firstChild.transparency.queryCache      ||= {}
  firstChild.transparency.queryCache[key] ||= jQuery(template).find "##{key}, #{key}, .#{key}, [data-bind='#{key}']"

ELEMENT_NODE = 1
map    ?= (f, xs) -> (f x for x in xs)
filter ?= (p, xs) -> (x   for x in xs when p x)
