(function() {
  var Transparency;

  if (typeof module !== 'undefined' && module.exports) {
    require('./spec_helper');
    Transparency = require('../src/transparency');
  }

  describe("Transparency", function() {
    it("should ignore null context", function() {
      var data, doc, expected;
      doc = jQuery('<div>\
      </div>');
      data = {
        hello: 'Hello'
      };
      expected = jQuery('<div>\
      </div>');
      window.Transparency.render(doc.find('.container').get(0), data);
      return expect(doc.html()).htmlToBeEqual(expected.html());
    });
    it("should work with null data", function() {
      var data, doc, expected;
      doc = jQuery('<div>\
        <div class="container">\
          <div class="hello"></div>\
          <div class="goodbye"></div>\
        </div>\
      </div>');
      data = null;
      expected = jQuery('<div>\
        <div class="container">\
        </div>\
      </div>');
      doc.find('.container').render(data);
      expect(doc.html()).htmlToBeEqual(expected.html());
      data = {
        hello: 'Hello'
      };
      expected = jQuery('<div>\
        <div class="container">\
          <div class="hello">Hello</div>\
          <div class="goodbye"></div>\
        </div>\
      </div>');
      doc.find('.container').render(data);
      return expect(doc.html()).htmlToBeEqual(expected.html());
    });
    it("should work with null values", function() {
      var data, doc, expected;
      doc = jQuery('<div>\
        <div class="container">\
          <div class="hello"></div>\
          <div class="goodbye"></div>\
        </div>\
      </div>');
      data = {
        hello: 'Hello',
        goodbye: null
      };
      expected = jQuery('<div>\
        <div class="container">\
          <div class="hello">Hello</div>\
          <div class="goodbye"></div>\
        </div>\
      </div>');
      doc.find('.container').render(data);
      return expect(doc.html()).htmlToBeEqual(expected.html());
    });
    it("should assing data values to template via CSS", function() {
      var data, doc, expected;
      doc = jQuery('<div>\
        <div class="container">\
          <div class="hello"></div>\
          <div class="goodbye"></div>\
        </div>\
      </div>');
      data = {
        hello: 'Hello',
        goodbye: 'Goodbye!'
      };
      expected = jQuery('<div>\
        <div class="container">\
          <div class="hello">Hello</div>\
          <div class="goodbye">Goodbye!</div>\
        </div>\
      </div>');
      doc.find('.container').render(data);
      return expect(doc.html()).htmlToBeEqual(expected.html());
    });
    it("should handle nested templates", function() {
      var data, doc, expected;
      doc = jQuery('<div>\
        <div class="container">\
          <div class="greeting">\
            <span class="name"></span>\
            <div class="greeting"></div>\
          </div>\
        </div>\
      </div>');
      data = {
        greeting: 'Hello',
        name: 'World'
      };
      expected = jQuery('<div>\
        <div class="container">\
          <div class="greeting">Hello<span class="name">World</span>\
            <div class="greeting">Hello</div>\
          </div>\
        </div>\
      </div>');
      doc.find('.container').render(data);
      return expect(doc.html()).htmlToBeEqual(expected.html());
    });
    it("should work with numeric values", function() {
      var data, doc, expected, res;
      doc = jQuery('<div>\
        <div class="container">\
          <div class="hello"></div>\
          <div class="goodbye"></div>\
        </div>\
      </div>');
      data = {
        hello: 'Hello',
        goodbye: 5
      };
      expected = jQuery('<div>\
        <div class="container">\
          <div class="hello">Hello</div>\
          <div class="goodbye">5</div>\
        </div>\
      </div>');
      res = doc.find('.container').render(data);
      return expect(doc.html()).htmlToBeEqual(expected.html());
    });
    it("should match by element id, class, name and data-bind", function() {
      var data, doc, expected, res;
      doc = jQuery('<div>\
        <div class="container">\
          <div id="my-id"></div>\
          <div class="my-class"></div>\
          <span></span>\
          <div data-bind="my-data"></div>\
        </div>\
      </div>');
      data = {
        'my-id': 'id-data',
        'my-class': 'class-data',
        span: 'name-data',
        'my-data': 'data-bind'
      };
      expected = jQuery('<div>\
        <div class="container">\
          <div id="my-id">id-data</div>\
          <div class="my-class">class-data</div>\
          <span>name-data</span>\
          <div data-bind="my-data">data-bind</div>\
        </div>\
      </div>');
      res = doc.find('.container').render(data);
      return expect(doc.html()).htmlToBeEqual(expected.html());
    });
    return it("should ignore functions in objects", function() {
      var data, doc, expected, res;
      doc = jQuery('<div>\
        <div class="container">\
          <div class="hello"></div>\
          <div class="goodbye"></div>\
          <div class="skipped"></div>\
        </div>\
      </div>');
      data = {
        hello: 'Hello',
        goodbye: 5,
        skipped: function() {
          return "hello";
        }
      };
      expected = jQuery('<div>\
        <div class="container">\
          <div class="hello">Hello</div>\
          <div class="goodbye">5</div>\
          <div class="skipped"></div>\
        </div>\
      </div>');
      res = doc.find('.container').render(data);
      return expect(doc.html()).htmlToBeEqual(expected.html());
    });
  });

}).call(this);
