(function() {
  var Transparency, expect, jsdom;

  jsdom = require("jsdom").jsdom;

  expect = require("./assert").expect;

  Transparency = require("../index");

  describe("Transparency", function() {
    return it("should work on node.js", function(done) {
      return jsdom.env("", [], function(errors, arg) {
        var data, document, expected, template;
        document = arg.document;
        template = document.createElement('div');
        template.innerHTML = "<div class=\"container\">\n  <div class=\"hello\"></div>\n</div>";
        data = {
          hello: 'Hello'
        };
        expected = document.createElement('div');
        expected.innerHTML = "<div class=\"container\">\n  <div class=\"hello\">Hello</div>\n</div>";
        Transparency.render(template, data);
        expect(template.innerHTML).toEqual(expected.innerHTML);
        return done();
      });
    });
  });

}).call(this);
