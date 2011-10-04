renderValues = (buffer, object) ->
  for key, value of object when typeof value == 'string'
    renderNode buffer, value if buffer.hasClass key or buffer.is key

    for node in buffer.find("#{key}, .#{key}")
      renderNode jQuery(node), value

renderForms = (buffer, object) ->
  parentKey = buffer.data 'key'
  return unless parentKey

  for key, value of object when typeof value == 'string'
    inputName = "#{parentKey}\\[#{key}\\]"

    if buffer.is('input') and buffer.attr('name') == inputName and buffer.attr('type') == 'text'
      renderNode buffer, value, 'value'

    for node in buffer.find("input[name=#{inputName}]")
      renderNode jQuery(node), value, 'value'

renderDirectives = (buffer, object, directives) ->
  for key, directive of directives when typeof directive == 'function'
    [key, attribute] = key.split('@')

    if buffer.hasClass key or buffer.is key
      renderNode buffer, directive.call(object, buffer), attribute

    for node in buffer.find("#{key}, .#{key}")
      node = jQuery(node)
      renderNode node, directive.call(object, node), attribute

renderChildren = (buffer, object, directives) ->
  for key, value of object when typeof value == 'object' and key != 'parent_'
    buffer.data 'key', key
    buffer.render value, directives[key], object if buffer.hasClass key
    buffer.find(".#{key}").render value, directives[key], object

renderNode = (node, value, attribute) ->
  if attribute
    node.attr attribute, value
  else
    children = node.children().detach()
    node.text value
    node.append children

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
      object.parent_ = parent if object

      renderValues     template, object
      renderForms      template, object
      renderDirectives template, object, directives
      renderChildren   template, object, directives
      context.append   template.html()

  return contexts

