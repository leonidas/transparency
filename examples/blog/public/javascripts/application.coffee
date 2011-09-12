showArticle = (article) ->
  $('.content').empty().append $('.template .show_article.page').clone()
  $('.content .article').render article

$ ->
  Spine.Route.add
    '/': () ->
      console.log '/'
      $('.content').empty().append $('.template .index.page').clone()
      $.getJSON '/articles.json', (articles) ->
        $('.content .articles').render articles, 'title@href': () -> ("/articles/#{this.id}")

    '/articles/:id': (params) ->
      console.log params.id
      $.getJSON "/articles/#{params.id}.json", showArticle

    '/articles/new': () ->
      console.log '/articles/new'
      $('.content').empty().append $('.template .new_article.page').clone()
      form = $('.content .new_article form')
      form.submit (event) ->
        event.preventDefault()
        $.post form.attr("action"), form.serialize(), (article) ->
          Spine.Route.navigate("/articles", article.id, true)

  Spine.Route.setup(history: true)
