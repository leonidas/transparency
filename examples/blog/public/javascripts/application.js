(function() {
  Path.map("/").to(function() {
    $('.content').empty().append($('.template .index.page').clone());
    return $.get('/.json', function(articles) {
      return $('.content .articles').render(articles, {
        'title@href': function() {
          return "/articles/" + this.id;
        }
      });
    });
  });
  Path.map("/articles/new").to(function() {
    return $('.content').empty().append($('.template .new_article.page').clone());
  });
  Path.map("/articles/:id").to(function() {
    $('.content').empty().append($('.template .show_article.page').clone());
    return $.get("/articles/" + this.params.id + ".json", function(article) {
      return $('.content .article').render(article);
    });
  });
  $(function() {
    $('.template').hide();
    Path.history.listen();
    return $('a').live('click', function(event) {
      Path.history.pushState({}, "", $(this).attr("href"));
      return event.preventDefault();
    });
  });
}).call(this);
