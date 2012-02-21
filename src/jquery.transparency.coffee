jQuery?.fn.render = (objects, directives) ->
  Transparency.render this.get(), objects, directives
  this

Transparency = @Transparency = {}

Transparency.render = (contexts, objects, directives) ->
  contexts     = if contexts.length? then Array.prototype.slice.call(contexts, 0) else [contexts] # NodeList to Array
  objects      = [objects] unless objects instanceof Array
  directives ||= {}
  template     = document.createElement 'div'

  for c in contexts
    c.t           ||= {}
    c.t.instances ||= []
    c.t.tc        ||= [] # Template cache. Query-cached templates are precious, so save them
    c.t.template  ||= (c.removeChild n while n = c.firstChild)
    sibling         = c.nextSibling
    parent          = c.parentNode
    parent?.removeChild c

    (c.t.instances.push c.t.tc.pop() || map ((n) -> n.cloneNode true), c.t.template) while objects.length > c.t.instances.length
    (c.t.tc.push (n.removeChild n) for n in c.t.instances.pop())                     while objects.length < c.t.instances.length

    for i, object of objects
      template.appendChild n for n in c.t.instances[i]
      renderValues     template, object
      renderDirectives template, object, directives
      renderChildren   template, object, directives
      (c.appendChild n) while n = template.firstChild

    if sibling then parent?.insertBefore(c, sibling) else parent?.appendChild c
  return contexts

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
    if fc = element.firstChild then element.insertBefore(text, fc) else element.appendChild text

matchingElements = (template, key) ->
  return [] unless fc = template.firstChild
  fc.t         ||= {}
  fc.t.qc      ||= {} # Query cache
  fc.t.qc[key] ||= if template.querySelectorAll
    template.querySelectorAll "##{key}, #{key}, .#{key}, [data-bind='#{key}']"
  else
    p = (e) ->
      e.id == key || e.nodeName.toLowerCase() == key.toLowerCase() || e.className.split(' ').indexOf(key) > -1 || e.getAttribute('data-bind') == key
    filter p, template.getElementsByTagName '*'

TEXT_NODE  = 3
map       ?= (f, xs) -> (f x for x in xs)
filter    ?= (p, xs) -> (x for x in xs when p(x))
