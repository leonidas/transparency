jQuery.fn.render = (data) ->
  data     = [data] unless jQuery.isArray(data)
  template = this

  jQuery.each data, (index, object) ->

    jQuery.each object, (key, value) ->
      #if value.isArray()
      #  render jQuery.find(key), value

      [klass, attribute] = key.split('@')
      template.find(".#{klass}").each ->
        if attribute
          jQuery(this).attr attribute, value
        else
          jQuery(this).prepend value

  return this