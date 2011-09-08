$ = jQuery

assign = (node, attribute, value) ->
  if attribute
    node.attr attribute, value
  else
    children = node.children().detach()
    node.text value
    node.append(children)

$.fn.render = (data) ->
  data     = [data] unless $.isArray(data)
  context  = this
  template = this.clone()

  # Iterate over the list of objects
  for object in data
    tmp = template.clone()

    # Iterate over keys in the object
    for key, value of object

      # Render child list
      if $.isArray(value)
        tmp.find(".#{key}").children().first().render(value)

      # Render child object
      else if typeof value == "object"
        tmp.find(".#{key}").render(value)

      # Assign attributes
      else
        [klass, attribute] = key.split('@')
        assign tmp, attribute, value if tmp.hasClass klass
        tmp.find(".#{klass}").each ->
          assign $(this), attribute, value

    # Add rendered template to dom
    context.before(tmp)

  return context.remove() # Remove the original template from dom
