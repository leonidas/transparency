(function() {

  if (typeof module !== 'undefined' && module.exports) {
    require('./spec_helper');
    require('../src/transparency');
  }

  describe("Transparency", function() {
    it("should handle nested lists", function() {
      var data, doc, expected;
      doc = jQuery('<div>\
       <div class="container">\
          <h1 class="title"></h1>\
          <p class="post"></p>\
          <div class="comments">\
            <div class="comment">\
              <span class="name"></span>\
              <span class="text"></span>\
            </div>\
          </div>\
        </div>\
      </div>');
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
      expected = jQuery('<div>\
       <div class="container">\
          <h1 class="title">Hello World</h1>\
          <p class="post">Hi there it is me</p>\
          <div class="comments">\
            <div class="comment">\
              <span class="name">John</span>\
              <span class="text">That rules</span>\
            </div>\
            <div class="comment">\
              <span class="name">Arnold</span>\
              <span class="text">Great post!</span>\
            </div>\
          </div>\
        </div>\
      </div>');
      doc.find('.container').render(data);
      return expect(doc.html()).htmlToBeEqual(expected.html());
    });
    it("should handle nested lists with overlapping attributes", function() {
      var data, doc, expected;
      doc = jQuery('<div>\
       <div class="container">\
          <p class="tweet"></p>\
          <div class="responses">\
            <p class="tweet"></p>\
          </div>\
        </div>\
      </div>');
      data = {
        responses: [
          {
            tweet: 'It truly is!'
          }, {
            tweet: 'I prefer JsUnit'
          }
        ],
        tweet: 'Jasmine is great!'
      };
      expected = jQuery('<div>\
       <div class="container">\
          <p class="tweet">Jasmine is great!</p>\
          <div class="responses">\
            <p class="tweet">It truly is!</p>\
            <p class="tweet">I prefer JsUnit</p>\
          </div>\
        </div>\
      </div>');
      doc.find('.container').render(data);
      return expect(doc.html()).htmlToBeEqual(expected.html());
    });
    it("should handle nested objects", function() {
      var data, doc, expected;
      doc = jQuery('<div>\
       <div class="container">\
          <div class="firstname"></div>\
          <div class="lastname"></div>\
          <div class="address">\
            <div class="street"></div>\
            <div class="zip"><span class="city"></span></div>\
          </div>\
        </div>\
      </div>');
      data = {
        firstname: 'John',
        lastname: 'Wayne',
        address: {
          street: '4th Street',
          city: 'San Francisco',
          zip: '94199'
        }
      };
      expected = jQuery('<div>\
       <div class="container">\
          <div class="firstname">John</div>\
          <div class="lastname">Wayne</div>\
          <div class="address">\
            <div class="street">4th Street</div>\
            <div class="zip">94199<span class="city">San Francisco</span></div>\
          </div>\
        </div>\
      </div>');
      doc.find('.container').render(data);
      return expect(doc.html()).htmlToBeEqual(expected.html());
    });
    return it("should handle tables with dynamic headers", function() {
      var data, directives, doc, expected;
      doc = jQuery('<div>\
       <table class="test_reports">\
          <thead>\
            <tr class="profiles">\
              <th>\
                <a class="name" href="#"></a>\
              </th>\
            </tr>\
          </thead>\
          <tbody>\
            <tr class="profiles">\
              <td class="testsets">\
                <div class="testset">\
                  <a class="name" href="#"></a>\
                  <ul class="products">\
                    <li>\
                      <a class="name" href="#"></a>\
                    </li>\
                  </ul>\
                </div>\
              </td>\
            </tr>\
          </tbody>\
        </table>\
      </div>');
      data = {
        release: "1.2",
        profiles: [
          {
            name: 'Core',
            testsets: [
              {
                name: "Sanity",
                products: [
                  {
                    name: "N900"
                  }, {
                    name: "Lenovo"
                  }
                ]
              }, {
                name: "Acceptance",
                products: [
                  {
                    name: "Netbook"
                  }, {
                    name: "Pinetrail"
                  }
                ]
              }
            ]
          }, {
            name: 'Handset',
            testsets: [
              {
                name: "Feature",
                products: [
                  {
                    name: "N900"
                  }, {
                    name: "Lenovo"
                  }
                ]
              }, {
                name: 'NFT',
                products: [
                  {
                    name: "Netbook"
                  }, {
                    name: "iCDK"
                  }
                ]
              }
            ]
          }
        ]
      };
      directives = {
        profiles: {
          name: function() {
            return {
              href: "/" + this.name
            };
          },
          testsets: {
            name: function() {
              return {
                href: "/" + this.name
              };
            },
            products: {
              name: function() {
                return {
                  href: "/" + this.name
                };
              }
            }
          }
        }
      };
      expected = jQuery('<div>\
       <table class="test_reports">\
          <thead>\
            <tr class="profiles">\
              <th>\
                <a class="name" href="/Core">Core</a>\
              </th>\
              <th>\
                <a class="name" href="/Handset">Handset</a>\
              </th>\
            </tr>\
          </thead>\
          <tbody>\
            <tr class="profiles">\
              <td class="testsets">\
                <div class="testset">\
                  <a class="name" href="/Sanity">Sanity</a>\
                  <ul class="products">\
                    <li>\
                      <a class="name" href="/N900">N900</a>\
                    </li>\
                    <li>\
                      <a class="name" href="/Lenovo">Lenovo</a>\
                    </li>\
                  </ul>\
                </div>\
                <div class="testset">\
                  <a class="name" href="/Acceptance">Acceptance</a>\
                  <ul class="products">\
                    <li>\
                      <a class="name" href="/Netbook">Netbook</a>\
                    </li>\
                    <li>\
                      <a class="name" href="/Pinetrail">Pinetrail</a>\
                    </li>\
                  </ul>\
                </div>\
              </td>\
              <td class="testsets">\
                <div class="testset">\
                  <a class="name" href="/Feature">Feature</a>\
                  <ul class="products">\
                    <li>\
                      <a class="name" href="/N900">N900</a>\
                    </li>\
                    <li>\
                      <a class="name" href="/Lenovo">Lenovo</a>\
                    </li>\
                  </ul>\
                </div>\
                <div class="testset">\
                  <a class="name" href="/NFT">NFT</a>\
                  <ul class="products">\
                    <li>\
                      <a class="name" href="/Netbook">Netbook</a>\
                    </li>\
                    <li>\
                      <a class="name" href="/iCDK">iCDK</a>\
                    </li>\
                  </ul>\
                </div>\
              </td>\
            </tr>\
          </tbody>\
        </table>\
      </div>');
      doc.find('.test_reports').render(data, directives);
      return expect(doc.html()).htmlToBeEqual(expected.html());
    });
  });

}).call(this);
