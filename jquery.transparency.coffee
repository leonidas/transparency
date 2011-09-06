jQuery.fn.render = (data) ->
  template = this

  if jQuery.isArray(data)
    parent = template.parent()
    #console.log(parent.html())
    template.remove()
    jQuery.each data, (index, value) ->
      template.clone().render(value).appendTo(parent)
      #console.log render.html()
      #parent.append(render)
      #console.log(parent.html())
      #render.appendTo(parent)
  else
    jQuery.each data, (key, value) ->

      [klass, attribute] = key.split('@')
      template.find(".#{klass}").each ->
        if attribute
          jQuery(this).attr attribute, value
        else
          jQuery(this).prepend value

  return this
