(function() {
  describe("Each element in a template instance", function() {
    return it("should have reference to the rendered model", function() {
      var data, directives, element, i, li, template, _i, _len, _ref, _results;
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
      _ref = template.find('li');
      _results = [];
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        li = _ref[i];
        _results.push((function() {
          var _j, _len1, _ref1, _results1;
          _ref1 = $(li).add('*', li);
          _results1 = [];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            element = _ref1[_j];
            _results1.push(expect(data[i]).toEqual(element.transparency.model));
          }
          return _results1;
        })());
      }
      return _results;
    });
  });

}).call(this);
