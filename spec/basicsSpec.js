(function() {
  describe("Transparency", function() {
    it("should ignore null context", function() {
      var data, expected, template;
      template = $('<div></div>');
      data = {
        hello: 'Hello'
      };
      expected = $('<div></div>');
      window.Transparency.render(template.find('#not_found')[0], data);
      return expect(template).toBeEqual(expected);
    });
    it("should render empty container for null data", function() {
      var data, expected, template;
      template = jQuery("<div class=\"container\">\n  <div class=\"hello\"></div>\n  <div class=\"goodbye\"></div>\n</div>");
      data = null;
      expected = $("<div class=\"container\">\n</div>");
      template.render(data);
      expect(template).toBeEqual(expected);
      data = {
        hello: 'Hello'
      };
      expected = $("<div class=\"container\">\n  <div class=\"hello\">Hello</div>\n  <div class=\"goodbye\"></div>\n</div>");
      template.render(data);
      return expect(template).toBeEqual(expected);
    });
    it("should ignore null values", function() {
      var data, expected, template;
      template = $("<div class=\"container\">\n  <div class=\"hello\"></div>\n  <div class=\"goodbye\"></div>\n</div>");
      data = {
        hello: 'Hello',
        goodbye: null
      };
      expected = $("<div class=\"container\">\n  <div class=\"hello\">Hello</div>\n  <div class=\"goodbye\"></div>\n</div>");
      template.render(data);
      return expect(template).toBeEqual(expected);
    });
    it("should match model keys to template by element id, class, name attribute and data-bind attribute", function() {
      var data, expected, template;
      template = $("<div class=\"container\">\n  <div id=\"my-id\"></div>\n  <div class=\"my-class\"></div>\n  <input name=\"my-name\" />\n  <div data-bind=\"my-data\"></div>\n</div>");
      data = {
        'my-id': 'id-data',
        'my-class': 'class-data',
        'my-name': 'name-data',
        'my-data': 'data-bind'
      };
      expected = $("<div class=\"container\">\n  <div id=\"my-id\">id-data</div>\n  <div class=\"my-class\">class-data</div>\n  <input name=\"my-name\" value=\"name-data\" />\n  <div data-bind=\"my-data\">data-bind</div>\n</div>");
      template.render(data);
      return expect(template).toBeEqual(expected);
    });
    it("should handle nested templates", function() {
      var data, expected, template;
      template = $("<div class=\"container\">\n  <div class=\"greeting\">\n    <span class=\"name\"></span>\n    <div class=\"greeting\"></div>\n  </div>\n</div>");
      data = {
        greeting: 'Hello',
        name: 'World'
      };
      expected = $("<div class=\"container\">\n  <div class=\"greeting\">Hello<span class=\"name\">World</span>\n    <div class=\"greeting\">Hello</div>\n  </div>\n</div>");
      template.render(data);
      return expect(template).toBeEqual(expected);
    });
    it("should handle numeric values", function() {
      var data, expected, template;
      template = $("<div class=\"container\">\n  <div class=\"hello\"></div>\n  <div class=\"goodbye\"></div>\n</div>");
      data = {
        hello: 'Hello',
        goodbye: 5
      };
      expected = $("<div class=\"container\">\n  <div class=\"hello\">Hello</div>\n  <div class=\"goodbye\">5</div>\n</div>");
      template.render(data);
      return expect(template).toBeEqual(expected);
    });
    it("should handle DOM elements as models", function() {
      var data, expected, template, widget1, widget2;
      template = $("<div id=\"template\">\n  <h1 class=\"title\"></h1>\n  <div class=\"widgets\">\n    <div class=\"widget\"></div>\n  </div>\n</div>");
      widget1 = $("<div>First</div>")[0];
      widget2 = $("<div>Second</div>")[0];
      data = {
        title: "Some widgets",
        widgets: [widget1, widget2]
      };
      expected = $("<div id=\"template\">\n  <h1 class=\"title\">Some widgets</h1>\n  <div class=\"widgets\">\n    <div class=\"widget\">\n      <div>First</div>\n    </div>\n    <div class=\"widget\">\n      <div>Second</div>\n    </div>\n  </div>\n</div>");
      template.render(data);
      return expect(template).toBeEqual(expected);
    });
    it("should convert date objects to strings", function() {
      var data, expected, template;
      template = $("<div class=\"container\">\n  <div class=\"best_before\"></div>\n</div>");
      data = {
        best_before: new Date(0)
      };
      expected = $("<div class=\"container\">\n  <div class=\"best_before\">" + ((new Date(0)).toString()) + "</div>\n</div>");
      template.render(data);
      return expect(template).toBeEqual(expected);
    });
    it("should ignore functions in models", function() {
      var data, expected, template;
      template = $("<div class=\"container\">\n  <div class=\"hello\"></div>\n  <div class=\"goodbye\"></div>\n  <div class=\"skipped\"></div>\n</div>");
      data = {
        hello: 'Hello',
        goodbye: 5,
        skipped: function() {
          return "hello";
        }
      };
      expected = $("<div class=\"container\">\n  <div class=\"hello\">Hello</div>\n  <div class=\"goodbye\">5</div>\n  <div class=\"skipped\"></div>\n</div>");
      template.render(data);
      return expect(template).toBeEqual(expected);
    });
    it("should preserve text between template elements", function() {
      var data, expected, template;
      template = $("<li class=\"foo\">\n<span data-bind=\"begin\"></span> - <span data-bind=\"end\"></span>\n</li>");
      data = {
        begin: 'asdf',
        end: 'fdsa'
      };
      expected = $("<li class=\"foo\">\n<span data-bind=\"begin\">asdf</span> - <span data-bind=\"end\">fdsa</span>\n</li>");
      template.render(data);
      return expect(template).toBeEqual(expected);
    });
    it("should render empty string, zero and other falsy values", function() {
      var data, expected, template;
      template = $("<div id=\"root\">\n    <span id=\"number\">234</span>\n    <span id=\"bool\">foo</span>\n    <span id=\"dec\">1.234</span>\n    <span id=\"str\">abc</span>\n</div>​");
      data = {
        number: 0,
        bool: false,
        dec: 0.0,
        str: ""
      };
      expected = $("<div id=\"root\">\n   <span id=\"number\">0</span>\n   <span id=\"bool\">false</span>\n   <span id=\"dec\">0</span>\n   <span id=\"str\"></span>\n </div>​");
      template.render(data);
      return expect(template).toBeEqual(expected);
    });
    return it("should not render text content to img tags and other void elements", function() {
      var data, directives, expected, template;
      template = $("<div id=\"gallery\">\n  <b data-bind=\"name\"></b>\n  <img data-bind=\"image\" src=\"\" alt=\"\" />\n</div>");
      data = [
        {
          name: 'gal1',
          image: 'http://example.com/image_name_1'
        }, {
          name: 'gal2',
          image: 'http://example.com/image_name_2'
        }
      ];
      directives = {
        name: {
          text: function() {
            return this.name;
          }
        },
        image: {
          src: function() {
            return this.image;
          }
        }
      };
      expected = $("<div id=\"gallery\">\n  <b data-bind=\"name\">gal1</b>\n  <img data-bind=\"image\" src=\"http://example.com/image_name_1\" alt=\"\" />\n  <b data-bind=\"name\">gal2</b>\n  <img data-bind=\"image\" src=\"http://example.com/image_name_2\" alt=\"\" />\n</div>");
      template.render(data, directives);
      return expect(template).toBeEqual(expected);
    });
  });

}).call(this);
