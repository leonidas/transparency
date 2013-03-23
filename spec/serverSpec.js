(function() {
  var Transparency, jsdom;

  require('./specHelper');

  jsdom = require("jsdom").jsdom;

  global.$ = require("jquery");

  Transparency = require("../index");

  $.fn.render = Transparency.jQueryPlugin;

  describe("Transparency", function() {
    return it("should work on node.js", function() {
      var data, expected, template;

      template = $("<div class=\"container\">\n  <div class=\"hello\"></div>\n</div>");
      data = {
        hello: 'Hello'
      };
      expected = $("<div class=\"container\">\n  <div class=\"hello\">Hello</div>\n</div>");
      template.render(data);
      return expect(template).toBeEqual(expected);
    });
  });

}).call(this);
