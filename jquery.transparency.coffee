_ = require "underscore"

jQuery.fn.render = (data) ->
  data     = [data] unless jQuery.isArray(data)
  template = this

  _(data).each (object) ->

    _(object).chain().keys().each (key) ->

      tmp       = key.split('@')
      klass     = tmp[0]
      attribute = tmp[1] if tmp.length > 1
      template.find(".#{klass}").each ->
        if attribute
          jQuery(this).attr attribute, object[key]
        else
          jQuery(this).prepend object[key]
  return this
