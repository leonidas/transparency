jQuery.fn.render = (data) ->
  data     = [data] unless jQuery.isArray(data)
  context  = this
  template = this.clone()

  # Iterate over data objects
  jQuery.each data, (index, object) ->
    tmp = template.clone()

    # Iterate over keys in the data object
    jQuery.each object, (key, value) ->

      [klass, attribute] = key.split('@')
      tmp.find(".#{klass}").each ->

        if attribute
          jQuery(this).attr attribute, value
        else
          jQuery(this).prepend value
    
    # Add rendered template to dom
    context.before(tmp)

  return context.remove()

'        <div class="container">          <div class="comment">            <span class="name">John</span>            <span class="text">That rules</span>          </div>        </div><div class="container">          <div class="comment">            <span class="name">Arnold</span>            <span class="text">Great post!</span>          </div>        </div>      '

'        <div class="container">          <div class="comment">            <span class="name">John</span>            <span class="text">That rules</span>          </div>          <div class="comment">            <span class="name">Arnold</span>            <span class="text">Great post!</span>          </div>        </div>      '