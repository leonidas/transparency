jQuery.fn.render = (data, directives, parent) ->
  contexts     = this
  data         = [data] unless jQuery.isArray(data)
  directives ||= {}

  for context in contexts
    context = jQuery(context)
    context.data('template', context.clone()) unless context.data 'template'
    context.empty()

    for object in data
      object.parent_ = parent if object
      template       = context.data('template').clone()
      template.data 'key', context.data 'key'

      renderValues     template, object
      renderForms      template, object
      renderDirectives template, object, directives
      renderChildren   template, object, directives
      context.append   template.children().clone true, true

  return contexts

renderValues = (template, object) ->
  for key, value of object when typeof value == 'string'
    if template.hasClass key or template.is key
      template.data 'object', object
      renderNode template, value

    for node in template.find("#{key}, .#{key}")
      $node = jQuery(node)
      $node.data 'object', object
      renderNode $node, value

renderForms = (template, object) ->
  parentKey = template.data 'key'
  return unless parentKey

  for key, value of object when typeof value == 'string'
    inputName = "#{parentKey}\\[#{key}\\]"

    if template.is('input') and template.attr('name') == inputName and template.attr('type') == 'text'
      renderNode template, value, 'value'

    for node in template.find("input[name=#{inputName}]")
      renderNode jQuery(node), value, 'value'

renderDirectives = (template, object, directives) ->
  for key, directive of directives when typeof directive == 'function'
    [key, attribute] = key.split('@')

    if template.hasClass key or template.is key
      renderNode template, directive.call(object, template), attribute

    for node in template.find("#{key}, .#{key}")
      node = jQuery(node)
      renderNode node, directive.call(object, node), attribute

renderChildren = (template, object, directives) ->
  for key, value of object when typeof value == 'object' and key != 'parent_'
    template.data 'key', key
    template.render value, directives[key], object if template.hasClass key

    template.find(".#{key}").data 'key', key
    template.find(".#{key}").render value, directives[key], object

renderNode = (node, value, attribute) ->
  if attribute
    node.attr attribute, value
  else
    children = node.children().detach()
    node.text value
    node.append children
