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
    fragment = context.ownerDocument.createDocumentFragment()
    for object, i in objects

      # Attach the elements from template instance to DocumentFragment for rendering
      (fragment.appendChild n) for n in context.transparency.instances[i]

      # Render the data
      renderValues      fragment, object
      renderDirectives  fragment, object, directives
      renderChildren    fragment, object, directives

      # Attach the results back to it's context
      context.appendChild fragment

    # Finally, put the context node back to it's original place in DOM
    if sibling then parent?.insertBefore(context, sibling) else parent?.appendChild context
  return contexts

prepareContext = (context, objects) ->
  # Extend context element with transparency hash to store the template and cached instances
  context.transparency                ||= {}
  context.transparency.template       ||= (context.removeChild context.firstChild while context.firstChild)
  context.transparency.templateCache  ||= [] # Query-cached templates are precious, so save them for the future
  context.transparency.instances      ||= [] # Currently used template instances

  # Get templates from the cache or clone new ones, if the cache is empty.
  while objects.length > context.transparency.instances.length
    template = context.transparency.templateCache.pop() || (map ((n) -> n.cloneNode true), context.transparency.template)
    context.transparency.instances.push template

  # Remove leftover templates from DOM and save them to the template cache for later use
  while objects.length < context.transparency.instances.length
    context.transparency.templateCache.push ((context.removeChild n) for n in context.transparency.instances.pop())

renderValues = (template, object) ->
  if typeof object == 'object'
    (setValue(e, v) for e in matchingElements(template, k)) for k, v of object when typeof v != 'object'
  else
    setValue(matchingElements(template, 'listElement')[0] || template.getElementsByTagName('*')[0], object)

renderDirectives = (template, object, directives) ->
  for key, directive of directives when typeof directive == 'function'
    [key, attribute] = key.split('@')
    (setValue node, directive.call(object, node), attribute) for node in matchingElements(template, key)

renderChildren = (template, object, directives) ->
  (Transparency.render matchingElements(template, k), v, directives[k]) for k, v of object when typeof v == 'object'

setValue = (element, value, attribute) ->
  if attribute
    element.setAttribute attribute, value
  else unless element?.t?.text == value
    (element.removeChild t) for t in filter ((n) -> n.nodeType == TEXT_NODE), element.childNodes
    element.t    ||= {}
    element.t.text = value
    text           = document.createTextNode(value)
    if element.firstChild
      element.insertBefore(text, element.firstChild)
    else
      element.appendChild text

matchingElements = (template, key) ->
  return [] unless firstChild = template.firstChild
  firstChild.transparency                 ||= {}
  firstChild.transparency.queryCache      ||= {}
  firstChild.transparency.queryCache[key] ||= if template.querySelectorAll
    template.querySelectorAll "##{key}, #{key}, .#{key}, [data-bind='#{key}']"
  else
    # Fallback for browsers which don't have implementation for DocumentFragment.querySelectorAll
    filter elementMatcher(key), template.getElementsByTagName '*'

elementMatcher = (key) ->
  (element) ->
    element.id == key ||
    element.nodeName.toLowerCase() == key.toLowerCase() ||
    element.className.split(' ').indexOf(key) > -1 ||
    element.getAttribute('data-bind') == key

TEXT_NODE  = 3
map       ?= (f, xs) -> (f x for x in xs)
filter    ?= (p, xs) -> (x   for x in xs when p(x))
