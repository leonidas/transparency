(function() {

  window.$(window.document).bind("ready", function() {
    var data, mustache_saved, mustache_t, result, transparency_t, weld_t;
    data = {
      name: "Joshua Kehn",
      interests: [
        {
          interest: "javascript"
        }, {
          interest: "node.js"
        }, {
          interest: "development"
        }, {
          interest: "programming"
        }
      ]
    };
    weld_t = window.$("#weld")[0];
    transparency_t = window.$("#transparency").get();
    mustache_t = window.$("#mustache")[0];
    mustache_saved = window.$("#mustache-saved").html();
    result = window.$("#result");
    return new window.Benchmark.Suite().add("transparency", function() {
      return window.t.render(transparency_t, data);
    }).add("weld", function() {
      return window.weld(weld_t, data);
    }).add("mustache", function() {
      return mustache_t.innerHTML = window.Mustache.to_html(mustache_saved, data);
    }).on("cycle", function(event, bench) {
      return result.append(String(bench) + '\n');
    }).on("complete", function() {
      result.append("Fastest is " + this.filter("fastest").pluck("name") + "\n");
      return result.trigger("complete");
    }).run(true);
  });

}).call(this);
