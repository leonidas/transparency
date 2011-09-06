jQuery.fn.render = (data) ->
  data     = [data] unless jQuery.isArray(data)
  template = this

  jQuery.each data, (index, object) ->

    jQuery.each object, (key, value) ->

      tmp       = key.split('@')
      klass     = tmp[0]
      attribute = tmp[1] if tmp.length > 1
      template.find(".#{klass}").each ->
        if attribute
          jQuery(this).attr attribute, value
        else
          jQuery(this).prepend value
  return this
