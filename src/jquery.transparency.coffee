jQuery.fn.render = (objects, directives) ->
  render this.get(), objects, directives
  this

window.t ||= {}

window.t.render = render = (contexts, objects, directives) ->
  contexts     = if typeof contexts.length == 'number' then (c for c in contexts) else [contexts] # NodeList to Array
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

    (c.t.instances.push (n.cloneNode(true) for n in c.t.template)) while c.t.instances.length < objects.length
    (c.removeChild(n) for n in c.t.instances.pop())                while c.t.instances.length > objects.length

    for object, i in objects
      template.appendChild n for n in c.t.instances[i]
      renderSimple     template, object
      renderValues     template, object
      renderDirectives template, object, directives
      renderChildren   template, object, directives

      (c.appendChild n) while n = template.firstChild

    if sibling then parent?.insertBefore(c, sibling) else parent?.appendChild c
  return contexts

renderSimple = (template, object) ->
  unless typeof object == 'object'
    node = template.querySelector(".listElement") || template.querySelector("*")
    renderNode node, object

renderValues = (template, object) ->
  for key, value of object when typeof value != 'object'
    (renderNode e, value) for e in matchingElements(template, key)

renderDirectives = (template, object, directives) ->
  for key, directive of directives when typeof directive == 'function'
    [key, attribute] = key.split('@')
    (renderNode node, directive.call(object, node), attribute) for node in matchingElements(template, key)

renderChildren = (template, object, directives) ->
  (render matchingElements(template, key), value, directives[key]) for key, value of object when typeof value == 'object'

renderNode = (element, value, attribute) ->
  if attribute
    element.setAttribute attribute, value
  else if element?.t?.text != value
    (element.removeChild t) for t in (n for n in element.childNodes when n.nodeType == 3)
    element.insertBefore document.createTextNode(value), element.firstChild
    element.t    ||= {}
    element.t.text = value

matchingElements = (template, key) ->
  template.querySelectorAll "##{key}, #{key}, .#{key}, [data-bind='#{key}']"
