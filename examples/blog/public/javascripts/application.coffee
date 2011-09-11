Path.map("/").to ->
  $('.content').empty().append $('.template .index.page').clone()

  $.get '/.json', (articles) ->
    $('.content .articles').render articles

Path.map("/articles/new").to ->
  $('.content').empty().append $('.template .new_article.page').clone()

$ ->
  $('.template').hide()
  Path.history.listen()

  $('a').live 'click', (event) ->
    Path.history.pushState {}, "", $(this).attr("href")
    event.preventDefault()