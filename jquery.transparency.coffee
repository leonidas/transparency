$ = jQuery

assign = (node, attribute, value) ->
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
    values  = select(object, (key, value) -> typeof value == "string")
    objects = select(object, (key, value) -> typeof value == "object")
    result  = template.clone()

    for key, value of values
      [klass, attribute] = key.split('@')
      assign result, attribute, value if result.hasClass klass
      result.find(".#{klass}").each ->
        assign $(this), attribute, value

    for key, directive of directives
      [klass, attribute] = key.split('@')
      value = directive(object)
      assign result, attribute, value if result.hasClass klass
      result.find(".#{klass}").each ->
        assign $(this), attribute, value

    for key, value of objects
      result.find(".#{key}").render(value)

    # Add rendered template to the dom
    context.before(result)

  return context.remove() # Remove the original template from the dom
