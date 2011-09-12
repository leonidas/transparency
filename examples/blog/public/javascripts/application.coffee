$ ->
  Spine.Route.add
    '/': () ->
      $('.content').empty().append $('.template .index.page').clone()
      $.getJSON '/articles.json', (articles) ->
        $('.content .articles').render articles, 'title@href': () -> ("/articles/#{this.id}")

    '/articles/:id': (params) ->
      $.getJSON "/articles/#{params.id}.json", (article) ->
        $('.content').empty().append $('.template .show_article.page').clone()
        $('.content .article').render article

    '/articles/new': () ->
      $('.content').empty().append $('.template .new_article.page').clone()
      form = $('.content .new_article form')
      form.submit (event) ->
        event.preventDefault()
        $.post form.attr("action"), form.serialize(), (article_path) ->
          Spine.Route.navigate(article_path, true)

  Spine.Route.setup(history: true)
