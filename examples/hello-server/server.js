var express      = require("express"),
    jsdom        = require("jsdom").jsdom,
    $            = require("jquery"),
    Transparency = require("../../index"),
    app;

$.fn.render = Transparency.jQueryPlugin;

app = express();

app.configure(function() { app.use(app.router); });

app.configure("development", function() {
  app.use(express.errorHandler({
    dumpExceptions: true,
    showStack: true
  }));
});

app.get("/", function(req, res) {
  var data, result, template;

  data = [
    { title: "Hello"  },
    { title: "Howdy"  },
    { title: "Cheers" },
    { title: "Byebye" }
  ];
  template = $("<ul id=\"items\">\n  <li class=\"title\"></li>\n</ul>");
  result   = template.render(data);
  return res.send(template[0].outerHTML);
});

app.listen(3000);

console.log("Express server listening on port 3000 in %s mode", app.settings.env);
