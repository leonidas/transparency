$ = jQuery

renderKey = (key, value, buffer) ->
  [klass, attribute] = key.split('@')
  assignValue buffer, attribute, value if buffer.hasClass klass
  buffer.find(".#{klass}").each ->
    assignValue $(this), attribute, value

assignValue = (node, attribute, value) ->
  if attribute
    node.attr attribute, value
  else
    children = node.children().detach()
    node.text value
    node.append(children)

select = (object, fn) ->
  result = {}
  for key, value of object
    (result[key] = value) if fn key, value
  result

$.fn.render = (data, directives) ->
  directives ?= {}
  context     = if $.isArray(data) then this.children().first() else this
  template    = context.clone()
  data        = [data] unless $.isArray(data)

  for object in data
    values  = select(object, (key, value) -> typeof value == 'string')
    objects = select(object, (key, value) -> typeof value == 'object')
    buffer  = template.clone()

    for key, value of values
      renderKey key, value, buffer

    for key, directive of directives
      if typeof directive == 'function'
        value = directive.call(object)
        renderKey key, value, buffer

    for key, value of objects
      buffer.find(".#{key}").render value, directives[key]

    # Add rendered template to the dom
    context.before(buffer)

  return context.remove() # Remove the original template from the dom
