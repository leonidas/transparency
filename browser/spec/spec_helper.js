(function() {
  var jsdom;

  if (typeof module !== 'undefined' && module.exports) {
    jsdom = require('jsdom/lib/jsdom').jsdom;
    global.document = jsdom("<html><head></head><body>hello world</body></html>");
    global.window = document.createWindow();
    jsdom = require('jsdom');
    global.jQuery = require('jquery');
  }

  beforeEach(function() {
    return this.addMatchers({
      htmlToBeEqual: function(expected) {
        var actual, formatHtml;
        formatHtml = function(html) {
          return html.replace(/\s/g, '').toLowerCase();
        };
        actual = formatHtml(this.actual);
        expected = formatHtml(expected);
        this.message = function() {
          return actual + '\n\n' + expected;
        };
        return actual === expected;
      }
    });
  });

}).call(this);
