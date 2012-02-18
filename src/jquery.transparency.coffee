jQuery.fn.render = (objects, directives, parentKey) ->
  contexts     = this
  objects      = [objects] unless objects instanceof Array
  directives ||= {}

  for context in contexts
    context = jQuery(context)
    context.data('template', context.clone()) unless context.data 'template'
    context.empty()

    for object in objects
      template       = context.data('template').clone()

      renderSimple     template, object
      renderValues     template, object
      renderForms      template, object, parentKey
      renderDirectives template, object, directives
      renderChildren   template, object, directives
      context.append   template.children()

  return contexts

renderSimple = (template, object) ->
  unless typeof object == 'object'
    node = template.find(".listElement").get(0) || template.children().get(0)
    renderNode node, object

renderValues = (template, object) ->
  for key, value of object when typeof value != 'object'
    for e in matchingElements(template, key)
      renderNode e, value

renderForms = (template, object, parentKey) ->
  return unless parentKey

  for key, value of object when typeof value != 'object'
    inputName = "#{parentKey}\\[#{key}\\]"

    if template.is('input') and template.attr('name') == inputName and template.attr('type') == 'text'
      renderNode template, value, 'value'

    for node in template.find("input[name=#{inputName}]")
      renderNode node, value, 'value'

renderDirectives = (template, object, directives) ->
  for key, directive of directives when typeof directive == 'function'
    [key, attribute] = key.split('@')

    for node in matchingElements(template, key)
      renderNode node, directive.call(object, node), attribute

renderChildren = (template, object, directives) ->
  for key, value of object when typeof value == 'object'
    matchingElements(template, key)
      .render value, directives[key], key

renderNode = (element, value, attribute) ->
  if attribute
    element.setAttribute attribute, value
  else
    # Find & remove existing text nodes
    for t in (n for n in element.childNodes when n.nodeType == 3)
      element.removeChild t

    element.insertBefore document.createTextNode(value), element.firstChild

matchingElements = (template, key) ->
  template.find("##{key}, #{key}, .#{key}, [data-bind='#{key}']")
