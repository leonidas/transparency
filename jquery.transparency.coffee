$ = jQuery

$.fn.render = (data) ->
  data     = [data] unless $.isArray(data)
  context  = this
  template = this.clone()

  # Iterate over data objects
  $.each data, (index, object) ->
    tmp = template.clone()

    # Iterate over keys in the data object
    $.each object, (key, value) ->

      # Render child template
      if $.isArray(value)
        tmp.find(".#{key}").children().first().render(value)
      else
        [klass, attribute] = key.split('@')
        if tmp.hasClass klass
          if attribute
            tmp.attr attribute, value
          else
            tmp.text value
        else
          tmp.find(".#{klass}").each ->
            if attribute
              $(this).attr attribute, value
            else
              $(this).prepend value
    
    # Add rendered template to dom
    context.before(tmp)
  
  return context.remove()
