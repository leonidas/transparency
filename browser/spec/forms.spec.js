(function() {

  if (typeof module !== 'undefined' && module.exports) {
    require('./spec_helper');
    window.Transparency = require('../src/transparency');
  }

  describe("Transparency", function() {
    it("should render values to form inputs and textarea elements", function() {
      var data, doc, expected;
      doc = document.createElement('div');
      doc.innerHTML = '<input name="name" type="text" />\
      <input name="job" type="text" />\
      <textarea name="resume"></textarea>';
      data = {
        name: 'John',
        job: 'Milkman',
        resume: "Jack of all trades"
      };
      expected = document.createElement('div');
      expected.innerHTML = '<input name="name" type="text" value="John"/>\
      <input name="job" type="text" value="Milkman"/>\
      <textarea name="resume">Jack of all trades</textarea>';
      jQuery(doc).render(data);
      return expect(doc.innerHTML).htmlToBeEqual(expected.innerHTML);
    });
    it("should render values to option elements", function() {
      var data, directives, doc, expected;
      doc = document.createElement('form');
      doc.innerHTML = '\
      <select id="states">\
        <option class="state"></option>\
      </select>';
      data = {
        states: [
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
        ]
      };
      directives = {
        states: {
          state: function() {
            return {
              value: this.id
            };
          }
        }
      };
      expected = '\
      <select id="states">\
        <option class="state" value="1">Alabama</option>\
        <option class="state" value="2">Alaska</option>\
        <option class="state" value="3">Arizona</option>\
      </select>';
      jQuery(doc).render(data, directives);
      return expect(doc.innerHTML).htmlToBeEqual(expected);
    });
    return it("should handle nested options", function() {
      var data, doc, expected;
      doc = jQuery('<div>\
        <div class="container">\
          <h1 class="title"></h1>\
          <p class="post"></p>\
          <select class="comments">\
            <option class="comment">test</option>\
          </select>\
        </div>\
      </div>');
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
      expected = jQuery('<div>\
        <div class="container">\
          <h1 class="title">Hello World</h1>\
          <p class="post">Hi there it is me</p>\
          <select class="comments">\
            <option class="comment">John</option>\
            <option class="comment">Arnold</option>\
          </select>\
        </div>\
      </div>');
      doc.find('.container').render(data);
      return expect(doc.html()).htmlToBeEqual(expected.html());
    });
  });

}).call(this);
