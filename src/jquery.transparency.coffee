jQuery.fn.render = (objects, directives) ->
  render this.get(), objects, directives
  this

window.t ?= {}

window.t.render = render = (contexts, objects, directives) ->
  contexts     = if contexts.length? then Array.prototype.slice.call(contexts, 0) else [contexts] # NodeList to Array
  objects      = [objects] unless objects instanceof Array
  directives ||= {}
  template     = document.createElement 'div'

  for c in contexts
    c.t           ||= {}
    c.t.instances ||= []
    c.t.template  ||= (c.removeChild n while n = c.firstChild)
    sibling         = c.nextSibling
    parent          = c.parentNode
    parent?.removeChild c

    (c.t.instances.push map(((n) -> n.cloneNode true), c.t.template)) while c.t.instances.length < objects.length
    (c.removeChild(n) for n in c.t.instances.pop())                   while c.t.instances.length > objects.length

    for i, object of objects
      template.appendChild n for n in c.t.instances[i]
      renderValues     template, object
      renderDirectives template, object, directives
      renderChildren   template, object, directives
      (c.appendChild n) while n = template.firstChild

    if sibling then parent?.insertBefore(c, sibling) else parent?.appendChild c
  return contexts

renderValues = (template, object) ->
  setValue(template.querySelector(".listElement") || template.querySelector("*"), object) unless typeof object == 'object'
  (setValue(e, v) for e in matchingElements(template, k)) for k, v of object when typeof v != 'object'

renderDirectives = (template, object, directives) ->
  for key, directive of directives when typeof directive == 'function'
    [key, attribute] = key.split('@')
    (setValue node, directive.call(object, node), attribute) for node in matchingElements(template, key)

renderChildren = (template, object, directives) ->
  (render matchingElements(template, k), v, directives[k]) for k, v of object when typeof v == 'object'

setValue = (element, value, attribute) ->
  if attribute
    element.setAttribute attribute, value
  else if element?.t?.text != value
    (element.removeChild t) for t in filter ((n) -> n.nodeType == TEXT_NODE), element.childNodes
    element.t    ||= {}
    element.t.text = value
    text           = document.createTextNode(value)
    sibling        = element.firstChild
    if sibling then element.insertBefore(text, sibling) else element.appendChild text

matchingElements = (template, key) ->
  template.querySelectorAll "##{key}, #{key}, .#{key}, [data-bind='#{key}']"

TEXT_NODE  = 3
map       ?= (f, xs) -> (f x for x in xs)
filter    ?= (p, xs) -> (x for x in xs when p(x))
