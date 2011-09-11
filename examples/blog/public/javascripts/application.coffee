Path.map("/").to ->
  $('.content').empty().append $('.template .index.page').clone()
  $.get '/.json', (articles) ->
    $('.content .articles').render articles, 'title@href': () -> ("/articles/#{this.id}")

Path.map("/articles/new").to ->
  $('.content').empty().append $('.template .new_article.page').clone()

Path.map("/articles/:id").to ->
  $('.content').empty().append $('.template .show_article.page').clone()
  $.get "/articles/#{this.params.id}.json", (article) ->
    $('.content .article').render article

$ ->
  $('.template').hide()
  Path.history.listen()

  $('a').live 'click', (event) ->
    Path.history.pushState {}, "", $(this).attr("href")
    event.preventDefault()