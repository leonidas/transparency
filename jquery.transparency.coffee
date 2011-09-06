jQuery.fn.render = (data) ->
  jQuery.fn.render = (data) ->
    context  = this
    template = this.clone()
    data     = [data] unless jQuery.isArray(data)
    context.empty()

    jQuery.each data, (index, object) ->
      tmp = template.clone()

      jQuery.each object, (key, value) ->
        [klass, attribute] = key.split('@')
        tmp.find(".#{klass}").each ->
          if attribute
            jQuery(this).attr attribute, value
          else
            jQuery(this).prepend value
      context.before(tmp)

    return context.last().remove()
