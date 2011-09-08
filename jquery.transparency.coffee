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

  # Iterate over data objects
  $.each data, (index, object) ->
    tmp = template.clone()

    # Iterate over keys in the data object
    $.each object, (key, value) ->

      # Render child objects
      if $.isArray(value)
        tmp.find(".#{key}").children().first().render(value)

      else
        [klass, attribute] = key.split('@')
        assign tmp, attribute, value if tmp.hasClass klass
        tmp.find(".#{klass}").each ->
          assign $(this), attribute, value

    # Add rendered template to dom
    context.before(tmp)
  
  return context.remove() # Remove template from dom
