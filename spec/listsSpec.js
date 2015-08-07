(function() {
  var expectModelObjects;

  describe("Transparency", function() {
    it("should render list of objects", function() {
      var data, expected, template;
      template = $("<div class=\"comments\">\n  <div class=\"comment\">\n    <span class=\"name\"></span><span class=\"text\"></span>\n  </div>\n</div>");
      data = [
        {
          name: 'John',
          text: 'That rules'
        }, {
          name: 'Arnold',
          text: 'Great post!'
        }
      ];
      expected = $("<div class=\"comments\">\n  <div class=\"comment\">\n    <span class=\"name\">John</span><span class=\"text\">That rules</span>\n  </div><div class=\"comment\">\n    <span class=\"name\">Arnold</span><span class=\"text\">Great post!</span>\n  </div>\n</div>");
      template.render(data);
      expect(template).toBeEqual(expected);
      expect(template.find('.comment')[0].transparency.model).toEqual(data[0]);
      return expectModelObjects(template.find('.comment'), data);
    });
    it("should render empty lists", function() {
      var data, expected, template;
      template = $("<div class=\"comments\">\n  <div class=\"comment\">\n    <span class=\"name\"></span>\n    <span class=\"text\"></span>\n  </div>\n</div>");
      data = [];
      expected = $("<div class=\"comments\">\n</div>");
      template.render(data);
      return expect(template).toBeEqual(expected);
    });
    it("should render lists with duplicate content", function() {
      var data, expected, template;
      template = $("<div id=\"items\">\n  <div class=\"name\"></div>\n</div>");
      data = [
        {
          name: "Same"
        }, {
          name: "Same"
        }
      ];
      expected = $("<div id=\"items\">\n  <div class=\"name\">Same</div>\n  <div class=\"name\">Same</div>\n</div>");
      template.render(data);
      return expect(template).toBeEqual(expected);
    });
    it("should render plain values with 'this' directives", function() {
      var data, directives, expected, template;
      template = $("<div class=\"comments\">\n  <label>Comment:</label>\n  <span class=\"comment\"></span>\n</div>");
      data = ["That rules", "Great post!", 5];
      directives = {
        comment: {
          text: function() {
            return this.value;
          }
        }
      };
      expected = $("<div class=\"comments\">\n  <label>Comment:</label>\n  <span class=\"comment\">That rules</span>\n  <label>Comment:</label>\n  <span class=\"comment\">Great post!</span>\n  <label>Comment:</label>\n  <span class=\"comment\">5</span>\n</div>");
      template.render(data, directives);
      return expect(template).toBeEqual(expected);
    });
    it("should not fail when there's no child node in the simple list template", function() {
      var data, expected, template;
      template = $("<div class=\"comments\">\n</div>");
      data = ["That rules", "Great post!"];
      expected = $("<div class=\"comments\">\n</div>");
      template.find('.comments').render(data);
      return expect(template).toBeEqual(expected);
    });
    return it("should match table rows to the number of model objects", function() {
      var template;
      template = $("<table>\n  <tbody class=\"users\">\n    <tr>\n      <td class=\"username\">foobar</td>\n    </tr>\n  </tbody>\n</table>");
      template.find(".users").render([
        {
          username: 'user1'
        }, {
          username: 'user2'
        }
      ]);
      expect(template).toBeEqual($("<table>\n  <tbody class=\"users\">\n    <tr>\n      <td class=\"username\">user1</td>\n    </tr>\n    <tr>\n      <td class=\"username\">user2</td>\n    </tr>\n  </tbody>\n</table>"));
      template.find(".users").render([
        {
          username: 'user1'
        }
      ]);
      expect(template).toBeEqual($("<table>\n  <tbody class=\"users\">\n    <tr>\n      <td class=\"username\">user1</td>\n    </tr>\n  </tbody>\n</table>"));
      template.find(".users").render([
        {
          username: 'user1'
        }, {
          username: 'user3'
        }
      ]);
      expect(template).toBeEqual($("<table>\n  <tbody class=\"users\">\n    <tr>\n      <td class=\"username\">user1</td>\n    </tr>\n    <tr>\n      <td class=\"username\">user3</td>\n    </tr>\n  </tbody>\n</table>"));
      template.find(".users").render([
        {
          username: 'user4'
        }, {
          username: 'user3'
        }
      ]);
      return expect(template).toBeEqual($("<table>\n  <tbody class=\"users\">\n    <tr>\n      <td class=\"username\">user4</td>\n    </tr>\n    <tr>\n      <td class=\"username\">user3</td>\n    </tr>\n  </tbody>\n</table>"));
    });
  });

  expectModelObjects = function(elements, data) {
    var i, j, len, object, results;
    results = [];
    for (i = j = 0, len = data.length; j < len; i = ++j) {
      object = data[i];
      results.push(expect(elements[i].transparency.model).toEqual(object));
    }
    return results;
  };

}).call(this);
