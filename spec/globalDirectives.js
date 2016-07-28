(function() {
  describe("Transparency", function() {
    return it("should render plain values with global directives", function() {
      var data, expected, globalDirective, template;
      globalDirective = {
        'global-test': {
          title: function(params) {
            return this.name;
          }
        },
        'global-backgroundColor': {
          style: function(params) {
            return 'background-color: ' + this.color;
          }
        }
      };
      template = $("<div>\n  <div data-bind=\"loop\">\n      <span data-bind=\"name\" class=\"global-test\"></span>\n      <div data-bind=\"cars\">\n          <span data-bind=\"color\" class=\"global-backgroundColor\"></span>\n      </div>\n      <hr>\n  </div>\n</div>");
      data = {
        loop: [
          {
            "name": "John",
            "cars": [
              {
                "color": "red"
              }, {
                "color": "blue"
              }
            ]
          }, {
            "name": "Michael",
            "cars": [
              {
                "color": "yellow"
              }, {
                "color": "green"
              }
            ]
          }
        ]
      };
      expected = $("<div>\n  <div data-bind=\"loop\">\n      <span data-bind=\"name\" class=\"global-test\" title=\"John\">John</span>\n      <div data-bind=\"cars\">\n          <span data-bind=\"color\" class=\"global-backgroundColor\" style=\"background-color: red\">red</span>\n          <span data-bind=\"color\" class=\"global-backgroundColor\" style=\"background-color: blue\">blue</span>\n      </div>\n      <hr>\n      <span data-bind=\"name\" class=\"global-test\" title=\"Michael\">Michael</span>\n      <div data-bind=\"cars\">\n          <span data-bind=\"color\" class=\"global-backgroundColor\" style=\"background-color: yellow\">yellow</span>\n          <span data-bind=\"color\" class=\"global-backgroundColor\" style=\"background-color: green\">green</span>\n      </div>\n      <hr>\n  </div>\n</div>");
      Transparency.setGlobalDirectives(globalDirective);
      template.render(data);
      return expect(template).toBeEqual(expected);
    });
  });

}).call(this);
