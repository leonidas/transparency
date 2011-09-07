jQuery.fn.render = (data) ->
  data     = [data] unless jQuery.isArray(data)
  context  = this
  template = this.clone()

  # Iterate over data objects
  jQuery.each data, (index, object) ->
    tmp = template.clone()

    # Iterate over keys in the data object
    jQuery.each object, (key, value) ->

      # Render child template
      if jQuery.isArray(value)
        tmp.find(".#{key}").children().first().render(value)
      else
        [klass, attribute] = key.split('@')
        tmp.find(".#{klass}").each ->

          if attribute
            jQuery(this).attr attribute, value
          else
            jQuery(this).prepend value
    
    # Add rendered template to dom
    context.before(tmp)
  
  return context.remove()
