jQuery.fn.render = (objects, directives) ->
  render this.get(), objects, directives
  this

window.t ||= {}

window.t.render = render = (contexts, objects, directives) ->
  contexts     = if typeof contexts.length == 'number' then (c for c in contexts) else [contexts] # NodeList to Array
  objects      = [objects]  unless objects instanceof Array
  directives ||= {}
  template     = document.createElement 'div'

  for context in contexts
    parent                = context.parentNode
    sibling               = context.nextSibling
    context.t           ||= {}
    context.t.instances ||= []
    context.t.template  ||= while n = context.firstChild
      context.removeChild(n)

    parent?.removeChild context

    while context.t.instances.length < objects.length
      t = for n in context.t.template
        n.cloneNode true
      context.t.instances.push t
    while context.t.instances.length > objects.length
      for n in context.t.instances.pop
        context.removeChild n

    for object, i in objects
      for n in context.t.instances[i]
        template.appendChild n

      renderSimple     template, object
      renderValues     template, object
      renderDirectives template, object, directives
      renderChildren   template, object, directives

      while n = template.firstChild
        context.appendChild n

    if sibling then parent?.insertBefore context, sibling else parent?.appendChild context
  return contexts

renderSimple = (template, object) ->
  unless typeof object == 'object'
    node = template.querySelector(".listElement") || template.querySelector("*")
    renderNode node, object

renderValues = (template, object) ->
  for key, value of object when typeof value != 'object'
    for e in matchingElements(template, key)
      renderNode e, value

renderDirectives = (template, object, directives) ->
  for key, directive of directives when typeof directive == 'function'
    [key, attribute] = key.split('@')

    for node in matchingElements(template, key)
      renderNode node, directive.call(object, node), attribute

renderChildren = (template, object, directives) ->
  for key, value of object when typeof value == 'object'
    render matchingElements(template, key), value, directives[key]

renderNode = (element, value, attribute) ->
  if attribute
    element.setAttribute attribute, value
  else if element?.t?.text != value
    for t in (n for n in element.childNodes when n.nodeType == 3)
      element.removeChild t
    element.insertBefore document.createTextNode(value), element.firstChild
    element.t    ||= {}
    element.t.text = value

matchingElements = (template, key) ->
  template.querySelectorAll "##{key}, #{key}, .#{key}, [data-bind='#{key}']"
