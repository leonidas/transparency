(function() {
  var showArticle;
  showArticle = function(article) {
    $('.content').empty().append($('.template .show_article.page').clone());
    return $('.content .article').render(article);
  };
  $(function() {
    Spine.Route.add({
      '/': function() {
        console.log('/');
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
        console.log(params.id);
        return $.getJSON("/articles/" + params.id + ".json", showArticle);
      },
      '/articles/new': function() {
        var form;
        console.log('/articles/new');
        $('.content').empty().append($('.template .new_article.page').clone());
        form = $('.content .new_article form');
        return form.submit(function(event) {
          event.preventDefault();
          return $.post(form.attr("action"), form.serialize(), function(article) {
            return Spine.Route.navigate("/articles", article.id, true);
          });
        });
      }
    });
    return Spine.Route.setup({
      history: true
    });
  });
}).call(this);
