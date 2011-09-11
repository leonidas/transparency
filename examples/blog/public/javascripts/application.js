(function() {
  Path.map("/").to(function() {
    $('.content').empty().append($('.template .index.page').clone());
    return $.get('/.json', function(articles) {
      return $('.content .articles').render(articles);
    });
  });
  Path.map("/articles/new").to(function() {
    return $('.content').empty().append($('.template .new_article.page').clone());
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
