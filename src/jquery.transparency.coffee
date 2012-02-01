jQuery.fn.render = (data, directives, parent) ->
  contexts     = this
  data         = [data] unless jQuery.isArray(data)
  directives ||= {}

  for context in contexts
    context = jQuery(context)
    context.data('template', context.clone()) unless context.data 'template'
    context.empty()

    for object in data
      template       = context.data('template').clone()
      template.data 'key', context.data 'key'

      renderValues     template, object
      renderForms      template, object
      renderDirectives template, object, directives
      renderChildren   template, object, directives
      context.append   template.children().clone true, true

  return contexts

renderValues = (template, object) ->
  for key, value of object when typeof value != 'object'
    for node in matchingElements(template, key)
      node = jQuery(node)
      node.data 'data', object
      renderNode node, value

renderForms = (template, object) ->
  parentKey = template.data 'key'
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
      .data('key', key)
      .render value, directives[key], object

renderNode = (node, value, attribute) ->
  if attribute
    node.attr attribute, value
  else
    children = node.children().detach()
    node.html value
    node.append children

matchingElements = (template, key) ->
  template.find(".#{key}, ##{key}, #{key}")
    .add(template if template.is(".#{key}, ##{key}, #{key}"))