$(document).ready ->
  state =
    example:  "assigning-values"
    template: "jade"
    code:     "coffee"

  $('#code, #template').keyup ->
    code = $('#code').val()
    template = $('#template').val()
    try
      template = jade.compile(template)() if state.template == "jade"
      $('#result').empty().append template
      code = CoffeeScript.compile(code, bare: on) if state.code == "coffee"
      eval code
      $('#source').empty().text style_html($('#result').html(), indent_size: 2)
      prettyPrint()
      $('#error').empty()
    catch error
      $('#error').text error.message

  $('.option').click (event) ->
    event.preventDefault()
    $(this).siblings().removeClass('active')
    $(this).addClass('active')
    option = $(event.target).attr 'id'
    console.log option
    switch option
      when "jade", "html"         then state.template = option
      when "coffee", "javascript" then state.code     = option
    updateCode()

  $('#examples').click (event) ->
    event.preventDefault()
    state.example = $(event.target).attr 'id'
    updateCode()

  updateCode = () ->
    switch state.code
      when "coffee" then $('#code').val window.examples[state.example]["coffee"]
      else $('#code').val CoffeeScript.compile(window.examples[state.example]["coffee"], bare: on)

    switch state.template
      when "jade" then $('#template').val window.examples[state.example]["jade"]
      else $('#template').val style_html(jade.compile(window.examples[state.example]["jade"])(), indent_size: 2)

    $('#code').trigger 'keyup'

  $('#examples a').first().trigger 'click'