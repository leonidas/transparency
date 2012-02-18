jQuery.fn.render = (objects, directives) ->
  render this.get(), objects, directives
  this

window.render = render = (contexts, objects, directives) ->
  contexts     = [contexts] unless typeof contexts.length == 'number' # NodeList isn't an instance of Array
  objects      = [objects]  unless objects instanceof Array
  directives ||= {}

  for context in contexts
    context.t                       ||= {}
    parent    = context.t.parent    ||= context
    instances = context.t.instances ||= []
    context.t.template              ||= while n = context.firstChild
      context.removeChild(n)

    i = 0
    while i < objects.length
      object   = objects[i]
      template = getTemplate context, i
      i += 1

      renderSimple     template, object
      renderValues     template, object
      renderDirectives template, object, directives
      renderChildren   template, object, directives

      while n = template.firstChild
        context.appendChild n

    # Remove leftover template instances
    while instances.length > objects.length
      for n in instances.pop
        parent.removeChild n

  return contexts

getTemplate = (context, i) ->
  template = document.createElement 'div'
  if i < context.t.instances.length
    for n in context.t.instances[i]
      template.appendChild n
    template
  else
    instance = for n in context.t.template
      template.appendChild(n.cloneNode true)
    context.t.instances.push instance
    template

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
