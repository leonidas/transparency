jQuery.fn.render = (data, directives, parentKey) ->
  contexts     = this
  data         = [data] unless data instanceof Array
  directives ||= {}

  for context in contexts
    context = jQuery(context)
    context.data('template', context.clone()) unless context.data 'template'
    context.empty()

    for object in data
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
    node = template.find(".listElement")
    unless (node.length)
      node = template.children().first()
    renderNode node, object

renderValues = (template, object) ->
  for key, value of object when typeof value != 'object'
    for node in matchingElements(template, key)
      node = jQuery(node)
      renderNode node, value

renderForms = (template, object, parentKey) ->
  return unless parentKey

  for key, value of object when typeof value != 'object'
    inputName = "#{parentKey}\\[#{key}\\]"

    if template.is('input') and template.attr('name') == inputName and template.attr('type') == 'text'
      renderNode template, value, 'value'

    for node in template.find("input[name=#{inputName}]")
      renderNode jQuery(node), value, 'value'

renderDirectives = (template, object, directives) ->
  for key, directive of directives when typeof directive == 'function'
    [key, attribute] = key.split('@')

    for node in matchingElements(template, key)
      node = jQuery(node)
      renderNode node, directive.call(object, node), attribute

renderChildren = (template, object, directives) ->
  for key, value of object when typeof value == 'object'
    matchingElements(template, key)
      .render value, directives[key], key

renderNode = (node, value, attribute) ->
  if attribute
    node.attr attribute, value
  else
    children = node.children().detach()
    node.html value
    node.append children

matchingElements = (template, key) ->
  template.find("##{key}, #{key}, .#{key}")
