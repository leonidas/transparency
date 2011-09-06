jQuery.fn.render = (data) ->
  template = this.clone()
  output   = ""

  if jQuery.isArray(data)
    jQuery.each data, (index, value) ->
      output += template.clone().render(value).html()

  else
    jQuery.each data, (key, value) ->

      [klass, attribute] = key.split('@')
      template.find(".#{klass}").each ->
        if attribute
          jQuery(this).attr attribute, value
        else
          jQuery(this).prepend value
    output += template.html()

  return jQuery("<div>#{output}</div>")
