renderKey = (key, value, buffer) ->
  [klass, attribute] = [element, _] = key.split('@')
  assignValue buffer, attribute, value if buffer.hasClass klass or buffer.is element
  buffer.find("#{element}, .#{klass}").each ->
    assignValue jQuery(this), attribute, value

assignValue = (node, attribute, value) ->
  if attribute
    throw "#{attribute}: Unsafe attribute assignment" if not validAttribute attribute
    node.attr attribute, value
  else
    children = node.children().detach()
    node.text value
    node.append children

validAttribute = (attribute) ->
  valids = [/^src$/, /^alt$/, 'id', /^href$/, /^class$/, /^data-*/]
  (true for valid in valids when attribute.match valid).length == 1

select = (object, fn) ->
  result = {}
  for key, value of object when fn key, value
    result[key] = value
  result

jQuery.fn.render = (data, directives) ->
  directives ||= {}
  context      = if jQuery.isArray(data) then this.children().first() else this
  template     = context.clone()
  data         = [data] unless jQuery.isArray(data)

  for object in data
    local_values     = select(object,     (key, value)     -> typeof value     == 'string'  )
    local_directives = select(directives, (key, directive) -> typeof directive == 'function')
    objects          = select(object,     (key, value)     -> typeof value     == 'object'  )
    buffer           = template.clone()

    for key, value of local_values
      renderKey key, value, buffer

    for key, directive of local_directives
      value = directive.call object
      renderKey key, value, buffer

    for klass, value of objects
      buffer.find(".#{klass}").add(key).render value, directives[klass]

    # Add the rendered template to the dom
    context.before(buffer)

  return context.remove() # Remove the original template from the dom
