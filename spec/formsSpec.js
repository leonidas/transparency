(function() {
  describe("Transparency", function() {
    it("should render values to form inputs and textarea elements", function() {
      var data, expected, template;
      template = $("<div>\n  <input name=\"name\"/>\n  <input name=\"job\"/>\n  <textarea name=\"resume\"></textarea>\n</div>");
      data = {
        name: 'John',
        job: 'Milkman',
        resume: "Jack of all trades"
      };
      expected = $("<div>\n  <input name=\"name\" value=\"John\"/>\n  <input name=\"job\" value=\"Milkman\"/>\n  <textarea name=\"resume\" value=\"Jack of all trades\"></textarea>\n</div>");
      expected.find('textarea').val('Jack of all trades');
      template.render(data);
      return expect(template).toBeEqual(expected);
    });
    it("should render values to option elements", function() {
      var data, directives, expected, template;
      template = $("<select id=\"states\">\n  <option class=\"state\"></option>\n</select>");
      data = [
        {
          id: 1,
          state: 'Alabama'
        }, {
          id: 2,
          state: 'Alaska'
        }, {
          id: 3,
          state: 'Arizona'
        }
      ];
      directives = {
        state: {
          value: function() {
            return this.id;
          }
        }
      };
      expected = $("<select id=\"states\">\n  <option class=\"state\" value=\"1\">Alabama</option>\n  <option class=\"state\" value=\"2\">Alaska</option>\n  <option class=\"state\" value=\"3\">Arizona</option>\n</select>");
      template.render(data, directives);
      template.children().first().prop('selected', true);
      return expect(template).toBeEqual(expected);
    });
    it("should render list of options and set the selected", function() {
      var data, directives, expected, template;
      template = $("<select class=\"foo\" multiple>\n    <option class=\"bar\"></option>\n</select>");
      data = [
        {
          id: 1,
          name: "First"
        }, {
          id: 2,
          name: "Second"
        }, {
          id: 3,
          name: "Third"
        }
      ];
      directives = {
        bar: {
          value: function() {
            return this.id;
          },
          text: function() {
            return this.name;
          },
          selected: function() {
            return true;
          }
        }
      };
      expected = $("<select class=\"foo\" multiple>\n    <option class=\"bar\" value=\"1\">First</option>\n    <option class=\"bar\" value=\"2\">Second</option>\n    <option class=\"bar\" value=\"3\">Third</option>\n</select>");
      template.render(data, directives);
      return expect(template).toBeEqual(expected);
    });
    it("should set the matching option to 'selected' in case the target element is 'select'", function() {
      var data, expected, template;
      template = $("<div>\n  <select class=\"state\">\n    <option value=\"1\">Alabama</option>\n    <option value=\"2\">Alaska</option>\n    <option value=\"3\">Arizona</option>\n  </select>\n</div>");
      data = {
        state: 2
      };
      expected = $("<div>\n  <select class=\"state\">\n    <option value=\"1\">Alabama</option>\n    <option value=\"2\" selected=\"selected\">Alaska</option>\n    <option value=\"3\">Arizona</option>\n  </select>\n</div>");
      template.render(data);
      return expect(template).toBeEqual(expected);
    });
    it("should handle nested options elements", function() {
      var data, expected, template;
      template = $("<div class=\"container\">\n  <h1 class=\"title\"></h1>\n  <p class=\"post\"></p>\n  <select class=\"comments\">\n    <option class=\"comment\">test</option>\n  </select>\n</div>");
      data = {
        title: 'Hello World',
        post: 'Hi there it is me',
        comments: [
          {
            comment: 'John'
          }, {
            comment: 'Arnold'
          }
        ]
      };
      expected = $("<div class=\"container\">\n  <h1 class=\"title\">Hello World</h1>\n  <p class=\"post\">Hi there it is me</p>\n  <select class=\"comments\">\n    <option class=\"comment\">John</option>\n    <option class=\"comment\">Arnold</option>\n  </select>\n</div>");
      template.render(data);
      return expect(template).toBeEqual(expected);
    });
    return it("should render checkbox and radiobutton checked attributes", function() {
      var data, expected, template;
      template = $("<div class=\"template\">\n  <input type=\"checkbox\" name=\"foo\" value=\"Foo\" />\n  <input type=\"checkbox\" name=\"foz\" value=\"Foz\" />\n  <input type=\"radio\" name=\"bar\" value=\"Bar\" />\n  <input type=\"radio\" name=\"baz\" value=\"Baz\" />\n</div>");
      data = {
        foo: true,
        foz: false,
        bar: true,
        baz: false
      };
      expected = $("<div class=\"template\">\n  <input type=\"checkbox\" name=\"foo\" value=\"Foo\" checked=\"checked\" />\n  <input type=\"checkbox\" name=\"foz\" value=\"Foz\" />\n  <input type=\"radio\" name=\"bar\" value=\"Bar\" checked=\"checked\" />\n  <input type=\"radio\" name=\"baz\" value=\"Baz\" />\n</div>");
      template.render(data);
      return expect(template).toBeEqual(expected);
    });
  });

}).call(this);
