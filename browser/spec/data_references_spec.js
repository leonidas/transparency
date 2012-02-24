(function() {

  if (typeof module !== 'undefined' && module.exports) {
    require('./spec_helper');
    require('../src/transparency');
  }

  describe("Transparency", function() {
    xit("should provide reference to original data", function() {
      var data, doc, person;
      doc = jQuery('<div>\
        <div class="person">\
          <span class="name"></span>\
          <span class="email"></span>\
        </div>\
      </div>');
      person = {
        name: 'Jasmine Taylor',
        email: 'jasmine.tailor@example.com'
      };
      doc.find('.person').render(person);
      data = doc.find('.name').data('data');
      return expect(data).toEqual(person);
    });
    return xit("should allow updating original data", function() {
      var data, doc, person;
      doc = jQuery('<div>\
        <div class="person">\
          <span class="name"></span>\
          <span class="email"></span>\
        </div>\
      </div>');
      person = {
        name: 'Jasmine Taylor',
        email: 'jasmine.tailor@example.com'
      };
      doc.find('.person').render(person);
      data = doc.find('.person .name').data('data');
      data.name = 'Frank Sinatra';
      return expect(data.name).toEqual(person.name);
    });
  });

}).call(this);
