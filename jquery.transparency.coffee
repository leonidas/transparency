jQuery.fn.render = (data) ->
  data     = [data] unless jQuery.isArray(data)
  parent   = this.parent()
  template = this.clone()
  this.remove()

  _(data).each (object) ->

    template = template.clone()
    _(object).chain().keys().each (key) ->

      tmp       = key.split('@')
      klass     = tmp[0]
      attribute = tmp[1] if tmp.length > 1
      template.find(".#{klass}").each ->
        if attribute
          jQuery(this).attr attribute, object[key]
        else
          jQuery(this).text object[key]
      
    parent.append(template)
  return parent
