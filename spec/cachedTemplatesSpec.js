(function() {
  describe("Transparency", function() {
    return it("cache templates", function() {
      var data, doc, expected;
      doc = $("<div>\n  <div class=\"container\">\n    <div>\n      <span class=\"hello\"></span>\n      <span class=\"world\"></span>\n    </div>\n  </div>\n</div>");
      data = [
        {
          hello: "Hello",
          world: "World!"
        }, {
          hello: "Goodbye",
          world: "Canada!"
        }
      ];
      expected = $("<div>\n  <div class=\"container\">\n    <div>\n      <span class=\"hello\">Hello</span>\n      <span class=\"world\">World!</span>\n    </div>\n    <div>\n      <span class=\"hello\">Goodbye</span>\n      <span class=\"world\">Canada!</span>\n    </div>\n  </div>\n</div>");
      doc.find('.container').render(data);
      doc.find('.container').render(data);
      return expect(doc).toBeEqual(expected);
    });
  });

}).call(this);
