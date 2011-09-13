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
  valids = ['src', 'alt', 'id', 'href', 'class', /^data-*/]
  (true for valid in valids when attribute.match valid).length == 1

jQuery.fn.render = (data, directives) ->
  directives ||= {}
  original     = this
  contexts     = if jQuery.isArray(data) then this.children() else [this]

  for context in contexts
    context   = jQuery(context)
    template  = context.clone()
    data      = [data] unless jQuery.isArray(data)

    for object in data
      buffer = template.clone()

      for key, value of object when typeof value == 'string'
        renderKey key, value, buffer

      for key, directive of directives when typeof directive == 'function'
        value = directive.call object
        renderKey key, value, buffer

      for klass, value of object when typeof value == 'object'
        buffer.render value, directives[klass] if buffer.hasClass klass
        buffer.find(".#{klass}").add(key).render value, directives[klass]

      # Add the rendered template to the dom
      context.before(buffer)
    
    context.remove() # Remove the original template from the dom

  return original
