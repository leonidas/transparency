_ = require 'underscore'
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
    #values = filter_by_value(object, (key, value) -> true )#typeof value == "string")
    # values  = _.map(object, (value, key) -> `{key : value}` )
    #console.log values
    # objects = _.select(object, (key, value) -> typeof value == "object")
    # lists   = _.select(object, (key, value) -> $.isArray() )
    tmp     = template.clone()

    for key, value of object
      if typeof value == "string"
        [klass, attribute] = key.split('@')
        assign tmp, attribute, value if tmp.hasClass klass
        tmp.find(".#{klass}").each ->
          assign $(this), attribute, value

    for key, value of object
      if $.isArray(value)
        tmp.find(".#{key}").children().first().render(value)

    for key, value of object
      if typeof value == "object" && not $.isArray(value)
        tmp.find(".#{key}").render(value)

    # Add rendered template to dom
    context.before(tmp)

  return context.remove() # Remove the original template from dom















