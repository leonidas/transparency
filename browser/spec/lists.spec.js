(function() {
  var expectModelObjects;

  if (typeof module !== 'undefined' && module.exports) {
    require('./spec_helper');
    require('../src/transparency');
  }

  describe("Transparency", function() {
    it("should handle list of objects", function() {
      var data, doc, expected;
      doc = jQuery('<div>\
        <div class="comments">\
          <div class="comment">\
            <span class="name"></span><span class="text"></span></div>\
        </div>\
      </div>');
      data = [
        {
          name: 'John',
          text: 'That rules'
        }, {
          name: 'Arnold',
          text: 'Great post!'
        }
      ];
      expected = jQuery('<div>\
        <div class="comments">\
          <div class="comment">\
            <span class="name">John</span><span class="text">That rules</span>\
          </div><div class="comment">\
            <span class="name">Arnold</span><span class="text">Great post!</span>\
          </div>\
        </div>\
      </div>');
      doc.find('.comments').render(data);
      expect(doc.html()).htmlToBeEqual(expected.html());
      expect(doc.find('.comment').get(0).transparency.model).toEqual(data[0]);
      return expectModelObjects(doc.find('.comment'), data);
    });
    it("should handle empty lists", function() {
      var data, doc, expected;
      doc = jQuery('<div>\
        <div class="comments">\
          <div class="comment">\
            <span class="name"></span>\
            <span class="text"></span>\
          </div>\
        </div>\
      </div>');
      data = [];
      expected = jQuery('<div>\
        <div class="comments">\
        </div>\
      </div>');
      doc.find('.comments').render(data);
      return expect(doc.html()).htmlToBeEqual(expected.html());
    });
    it("should render list containing simple values", function() {
      var data, doc, expected;
      doc = jQuery('<div>\
        <div class="comments">\
          <span></span>\
          <label>blah</label>\
        </div>\
      </div>');
      data = ["That rules", "Great post!"];
      expected = jQuery('<div>\
        <div class="comments">\
          <span>That rules</span><label>blah</label><span>Great post!</span><label>blah</label>\
        </div>\
      </div>');
      doc.find('.comments').render(data);
      expect(doc.html()).htmlToBeEqual(expected.html());
      return expectModelObjects(doc.find('span'), data);
    });
    it("should place simple value into element with listElement class if found", function() {
      var data, doc, expected;
      doc = jQuery('<div>\
        <div class="comments">\
          <label>comment</label><span class="listElement"></span>\
        </div>\
      </div>');
      data = ["That rules", "Great post!"];
      expected = jQuery('<div>\
        <div class="comments">\
          <label>comment</label><span class="listElement">That rules</span>\
          <label>comment</label><span class="listElement">Great post!</span>\
        </div>\
      </div>');
      doc.find('.comments').render(data);
      expect(doc.html()).htmlToBeEqual(expected.html());
      return expectModelObjects(doc.find('.listElement'), data);
    });
    it("should not fail when there's no child node in the simple list template", function() {
      var data, doc, expected;
      doc = jQuery('<div>\
        <div class="comments">\
        </div>\
      </div>');
      data = ["That rules", "Great post!"];
      expected = jQuery('<div>\
        <div class="comments">\
        </div>\
      </div>');
      doc.find('.comments').render(data);
      return expect(doc.html()).htmlToBeEqual(expected.html());
    });
    return it("should match table rows to the number of model objects", function() {
      var doc;
      doc = jQuery('<div>\
        <table>\
          <tbody class="users">\
            <tr>\
              <td class="username"></td>\
            </tr>\
          </tbody>\
        </table>\
      </div>');
      doc.find("tbody.users").render([
        {
          username: 'user1'
        }, {
          username: 'user2'
        }
      ]);
      expect(doc.html()).htmlToBeEqual(jQuery('\
      <div>\
        <table>\
          <tbody class="users">\
            <tr>\
              <td class="username">user1</td>\
            </tr>\
            <tr>\
              <td class="username">user2</td>\
            </tr>\
          </tbody>\
        </table>\
      </div>').html());
      doc.find("tbody.users").render([
        {
          username: 'user1'
        }
      ]);
      expect(doc.html()).htmlToBeEqual(jQuery('\
      <div>\
        <table>\
          <tbody class="users">\
            <tr>\
              <td class="username">user1</td>\
            </tr>\
          </tbody>\
        </table>\
      </div>').html());
      doc.find("tbody.users").render([
        {
          username: 'user1'
        }, {
          username: 'user3'
        }
      ]);
      expect(doc.html()).htmlToBeEqual(jQuery('\
      <div>\
        <table>\
          <tbody class="users">\
            <tr>\
              <td class="username">user1</td>\
            </tr>\
            <tr>\
              <td class="username">user3</td>\
            </tr>\
          </tbody>\
        </table>\
      </div>').html());
      doc.find("tbody.users").render([
        {
          username: 'user4'
        }, {
          username: 'user3'
        }
      ]);
      return expect(doc.html()).htmlToBeEqual(jQuery('\
      <div>\
        <table>\
          <tbody class="users">\
            <tr>\
              <td class="username">user4</td>\
            </tr>\
            <tr>\
              <td class="username">user3</td>\
            </tr>\
          </tbody>\
        </table>\
      </div').html());
    });
  });

  expectModelObjects = function(elements, data) {
    var i, object, _len, _results;
    _results = [];
    for (i = 0, _len = data.length; i < _len; i++) {
      object = data[i];
      _results.push(expect(elements.get(i).transparency.model).toEqual(object));
    }
    return _results;
  };

}).call(this);
