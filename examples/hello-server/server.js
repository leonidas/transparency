var express      = require('express'),
    jsdom        = require('jsdom').jsdom,
    doc          = jsdom('<html><body><ul id="items"><li class="title"></li></ul></body></html>'),
    Transparency = require('../../index'),
    helloTmpl    = doc.getElementsByTagName('ul')[0],
    count        = 0,
    app;

app = express();

app.configure(function() { app.use(app.router); });

app.configure('development', function() {
  app.use(express.errorHandler({
    dumpExceptions: true,
    showStack: true
  }));
});

app.get('/', function(req, res) {
  var data = [
    { title: 'Hello '  + count++},
    { title: 'Howdy '  + count++},
    { title: 'Cheers ' + count++},
    { title: 'Byebye ' + count++}
  ];

  return res.send(Transparency.render(helloTmpl, data).outerHTML);
});

app.listen(3000);

console.log('Express server listening on port 3000 in %s mode', app.settings.env);
