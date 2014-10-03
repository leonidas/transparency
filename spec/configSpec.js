(function() {
  describe("Transparency", function() {
    return it("should use a custom matcher if available", function() {
      var data, data_bind_matcher, default_matcher, expected_with_custom_matcher, template;
      template = $("<div class=\"container\">\n   <h1 data-bind=\"title\"></h1>\n   <p class=\"post\"></p>\n   <div data-bind=\"comments\">\n     <div class=\"comment\">\n       <span class=\"name\"></span>\n       <span data-bind=\"text\"></span>\n     </div>\n   </div>\n </div>");
      data = {
        title: 'Hello World',
        post: 'Hi there it is me',
        comments: [
          {
            name: 'John',
            text: 'That rules'
          }, {
            name: 'Arnold',
            text: 'Great post!'
          }
        ]
      };
      data_bind_matcher = function(element, key) {
        return element.el.getAttribute('data-bind') === key;
      };
      expected_with_custom_matcher = $("<div class=\"container\">\n  <h1 data-bind=\"title\">Hello World</h1>\n  <p class=\"post\"></p>\n  <div data-bind=\"comments\">\n    <div class=\"comment\">\n      <span class=\"name\"></span>\n      <span data-bind=\"text\">That rules</span>\n    </div>\n    <div class=\"comment\">\n      <span class=\"name\"></span>\n      <span data-bind=\"text\">Great post!</span>\n    </div>\n  </div>\n</div>");
      default_matcher = window.Transparency.matcher;
      window.Transparency.matcher = data_bind_matcher;
      template.render(data);
      expect(template).toBeEqual(expected_with_custom_matcher);
      return window.Transparency.matcher = default_matcher;
    });
  });

}).call(this);
