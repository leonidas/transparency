(function() {
  var jsdom;

  if (typeof module !== 'undefined' && module.exports) {
    jsdom = require('jsdom/lib/jsdom').jsdom;
    global.document = jsdom("<html><head></head><body>hello world</body></html>");
    global.window = document.createWindow();
    jsdom = require('jsdom');
    global.jQuery = require('jquery');
    jsdom.dom.level3.core.DocumentFragment.prototype.__proto__ = jsdom.dom.level3.core.Element.prototype;
  }

  beforeEach(function() {
    return this.addMatchers({
      htmlToBeEqual: function(expected) {
        var actual, formatHtml, message, result, row;
        formatHtml = function(html) {
          return html.replace(/\s\s+/g, '').replace(/></g, '>\n<').split('\n');
        };
        actual = formatHtml(this.actual);
        expected = formatHtml(expected);
        message = "";
        result = true;
        row = 0;
        while (row < Math.min(actual.length, expected.length)) {
          if (actual[row] !== expected[row]) {
            result = false;
            message = "Expected row " + (row + 1) + " to be equal:\nActual:  " + actual[row] + "\nExpected:" + expected[row];
            break;
          }
          row += 1;
        }
        this.message = function() {
          return message;
        };
        return result;
      }
    });
  });

}).call(this);
