(function() {
  describe("Each element in a template instance", function() {
    return it("should have reference to the rendered model", function() {
      var data, directives, element, i, j, len, li, ref, results, template;
      template = $("<div id=\"template\">\n    <li><a class=\"name\"><span>Moar text</span></a></div>\n</div>");
      data = [
        {
          name: 'Foo'
        }, {
          name: 'Bar'
        }
      ];
      directives = {
        name: {
          text: function(params) {
            expect(data[params.index]).toEqual(params.element.transparency.model);
            return this.name;
          }
        }
      };
      template.render(data, directives);
      ref = template.find('li');
      results = [];
      for (i = j = 0, len = ref.length; j < len; i = ++j) {
        li = ref[i];
        results.push((function() {
          var k, len1, ref1, results1;
          ref1 = $(li).add('*', li);
          results1 = [];
          for (k = 0, len1 = ref1.length; k < len1; k++) {
            element = ref1[k];
            results1.push(expect(data[i]).toEqual(element.transparency.model));
          }
          return results1;
        })());
      }
      return results;
    });
  });

}).call(this);
