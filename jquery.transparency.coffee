renderValue = (buffer, key, value) ->
  element = klass = key # Match both classes and elements
  renderNode buffer, value if buffer.hasClass klass or buffer.is element
  buffer.find("#{element}, .#{klass}").each ->
    renderNode jQuery(this), value

renderDirective = (buffer, key, directive, object) ->
  [klass, attribute] = [element, _] = key.split('@') # Match both classes and elements
  
  if buffer.hasClass klass or buffer.is element
    renderNode buffer, directive.call(object, buffer), attribute 

  buffer.find("#{element}, .#{klass}").each ->
    node = jQuery(this)
    renderNode node, directive.call(object, node), attribute

renderNode = (node, value, attribute) ->
  if attribute
    node.attr attribute, value
  else
    children = node.children().detach()
    node.text value
    node.append children

jQuery.fn.render = (data, directives) ->
  directives ||= {}
  result       = this
  contexts     = if jQuery.isArray(data) then @children() else [this]

  for context in contexts
    context   = jQuery(context)
    template  = context.clone()
    data      = [data] unless jQuery.isArray(data)

    for object in data
      buffer = template.clone()

      for key, value of object when typeof value == 'string'
        renderValue buffer, key, value

      for key, directive of directives when typeof directive == 'function'
        renderDirective buffer, key, directive, object

      for klass, value of object when typeof value == 'object'
        buffer.render value, directives[klass] if buffer.hasClass klass
        buffer.find(".#{klass}").add(key).render value, directives[klass]

      # Add the rendered template to the dom
      context.before(buffer)
    
    context.remove() # Remove the original template from the dom

  return result
