(function() {
  $(function() {
    Spine.Route.add({
      '/': function() {
        $('.content').empty().append($('.template .index.page').clone());
        return $.getJSON('/articles.json', function(articles) {
          return $('.content .articles').render(articles, {
            'title@href': function() {
              return "/articles/" + this.id;
            }
          });
        });
      },
      '/articles/:id': function(params) {
        return $.getJSON("/articles/" + params.id + ".json", function(article) {
          $('.content').empty().append($('.template .show_article.page').clone());
          return $('.content .article').render(article);
        });
      },
      '/articles/new': function() {
        var form;
        $('.content').empty().append($('.template .new_article.page').clone());
        form = $('.content .new_article form');
        return form.submit(function(event) {
          event.preventDefault();
          return $.post(form.attr("action"), form.serialize(), function(article_path) {
            return Spine.Route.navigate(article_path, true);
          });
        });
      }
    });
    return Spine.Route.setup({
      history: true
    });
  });
}).call(this);
