jQuery.fn.render = (objects, directives) ->
  contexts     = this
  objects      = [objects] unless objects instanceof Array
  directives ||= {}

  for context in contexts
    context.t ||= context.cloneNode(true)

    # Cleanup the template
    while (n = context.firstChild)
      context.removeChild n

    for object in objects
      template       = context.t.cloneNode true

      renderSimple     template, object
      renderValues     template, object
      renderDirectives template, object, directives
      renderChildren   template, object, directives
      while (n = template.firstChild)
        context.appendChild n

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
    jQuery(matchingElements(template, key))
      .render value, directives[key], key

renderNode = (element, value, attribute) ->
  if attribute
    element.setAttribute attribute, value
  else
    for t in (n for n in element.childNodes when n.nodeType == 3)
      element.removeChild t
    element.insertBefore document.createTextNode(value), element.firstChild

matchingElements = (template, key) ->
  template.querySelectorAll "##{key}, #{key}, .#{key}, [data-bind='#{key}']"
