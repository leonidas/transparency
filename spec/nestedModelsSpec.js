(function() {
  describe("Transparency", function() {
    it("should handle nested lists", function() {
      var data, expected, template;
      template = $("<div class=\"container\">\n   <h1 class=\"title\"></h1>\n   <p class=\"post\"></p>\n   <div class=\"comments\">\n     <div class=\"comment\">\n       <span class=\"name\"></span>\n       <span class=\"text\"></span>\n     </div>\n   </div>\n </div>");
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
      expected = $("<div class=\"container\">\n  <h1 class=\"title\">Hello World</h1>\n  <p class=\"post\">Hi there it is me</p>\n  <div class=\"comments\">\n    <div class=\"comment\">\n      <span class=\"name\">John</span>\n      <span class=\"text\">That rules</span>\n    </div>\n    <div class=\"comment\">\n      <span class=\"name\">Arnold</span>\n      <span class=\"text\">Great post!</span>\n    </div>\n  </div>\n</div>");
      template.render(data);
      return expect(template).toBeEqual(expected);
    });
    it("should handle nested lists with overlapping attributes", function() {
      var data, expected, template;
      template = $("<div class=\"container\">\n  <p class=\"tweet\"></p>\n  <div class=\"responses\">\n    <p class=\"tweet\"></p>\n  </div>\n</div>");
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
      expected = $("<div class=\"container\">\n  <p class=\"tweet\">Jasmine is great!</p>\n  <div class=\"responses\">\n    <p class=\"tweet\">It truly is!</p>\n    <p class=\"tweet\">I prefer JsUnit</p>\n  </div>\n</div>");
      template.render(data);
      return expect(template).toBeEqual(expected);
    });
    it("should handle nested objects", function() {
      var data, expected, template;
      template = $("<div class=\"container\">\n  <div class=\"firstname\"></div>\n  <div class=\"lastname\"></div>\n  <div class=\"address\">\n    <div class=\"street\"></div>\n    <div class=\"zip\"><span class=\"city\"></span></div>\n  </div>\n</div>");
      data = {
        firstname: 'John',
        lastname: 'Wayne',
        address: {
          street: '4th Street',
          city: 'San Francisco',
          zip: '94199'
        }
      };
      expected = $("<div class=\"container\">\n  <div class=\"firstname\">John</div>\n  <div class=\"lastname\">Wayne</div>\n  <div class=\"address\">\n    <div class=\"street\">4th Street</div>\n    <div class=\"zip\">94199<span class=\"city\">San Francisco</span></div>\n  </div>\n</div>");
      template.render(data);
      return expect(template).toBeEqual(expected);
    });
    it("should handle tables with dynamic headers", function() {
      var data, directives, expected, template;
      template = $("<table class=\"test_reports\">\n  <thead>\n    <tr class=\"profiles\">\n      <th>\n        <a class=\"name\" href=\"http://www.example.com\">profile</a>\n      </th>\n    </tr>\n  </thead>\n  <tbody>\n    <tr class=\"profiles\">\n      <td class=\"testsets\">\n        <div class=\"testset\">\n          <a class=\"name\" href=\"http://www.example.com\">testset</a>\n          <ul class=\"products\">\n            <li>\n              <a class=\"name\" href=\"http://www.example.com\">product</a>\n            </li>\n          </ul>\n        </div>\n      </td>\n    </tr>\n  </tbody>\n</table>");
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
          name: {
            href: function() {
              return "http://www.example.com/" + this.name;
            }
          },
          testsets: {
            name: {
              href: function() {
                return "http://www.example.com/" + this.name;
              }
            },
            products: {
              name: {
                href: function() {
                  return "http://www.example.com/" + this.name;
                }
              }
            }
          }
        }
      };
      expected = $("<table class=\"test_reports\">\n  <thead>\n    <tr class=\"profiles\">\n      <th>\n        <a class=\"name\" href=\"http://www.example.com/Core\">Core</a>\n      </th>\n      <th>\n        <a class=\"name\" href=\"http://www.example.com/Handset\">Handset</a>\n      </th>\n    </tr>\n  </thead>\n  <tbody>\n    <tr class=\"profiles\">\n      <td class=\"testsets\">\n        <div class=\"testset\">\n          <a class=\"name\" href=\"http://www.example.com/Sanity\">Sanity</a>\n          <ul class=\"products\">\n            <li>\n              <a class=\"name\" href=\"http://www.example.com/N900\">N900</a>\n            </li>\n            <li>\n              <a class=\"name\" href=\"http://www.example.com/Lenovo\">Lenovo</a>\n            </li>\n          </ul>\n        </div>\n        <div class=\"testset\">\n          <a class=\"name\" href=\"http://www.example.com/Acceptance\">Acceptance</a>\n          <ul class=\"products\">\n            <li>\n              <a class=\"name\" href=\"http://www.example.com/Netbook\">Netbook</a>\n            </li>\n            <li>\n              <a class=\"name\" href=\"http://www.example.com/Pinetrail\">Pinetrail</a>\n            </li>\n          </ul>\n        </div>\n      </td>\n      <td class=\"testsets\">\n        <div class=\"testset\">\n          <a class=\"name\" href=\"http://www.example.com/Feature\">Feature</a>\n          <ul class=\"products\">\n            <li>\n              <a class=\"name\" href=\"http://www.example.com/N900\">N900</a>\n            </li>\n            <li>\n              <a class=\"name\" href=\"http://www.example.com/Lenovo\">Lenovo</a>\n            </li>\n          </ul>\n        </div>\n        <div class=\"testset\">\n          <a class=\"name\" href=\"http://www.example.com/NFT\">NFT</a>\n          <ul class=\"products\">\n            <li>\n              <a class=\"name\" href=\"http://www.example.com/Netbook\">Netbook</a>\n            </li>\n            <li>\n              <a class=\"name\" href=\"http://www.example.com/iCDK\">iCDK</a>\n            </li>\n          </ul>\n        </div>\n      </td>\n    </tr>\n  </tbody>\n</table>");
      template.render(data, directives);
      return expect(template).toBeEqual(expected);
    });
    return it("should handle nested objects", function() {
      var data, directives, expected, template;
      template = $("<div id=\"archive\">\n  <a href=\"http://www.example.com\" class=\"yeartitle\"><span class=\"year\"></span></a>\n  <div class=\"payslips\">\n    <a href=\"http://www.example.com\" class=\"payslip\">\n      <span data-id=\"#\" class=\"id\"></span>\n      <span class=\"date PayDate\"></span>\n      <span class=\"payment\">\n      <span class=\"NetPayment\"></span>\n      <span>EUR</span></span>\n      <span class=\"payer Payer\"></span>\n    </a>\n  </div>\n</div>");
      directives = {
        payslips: {
          id: {
            "data-id": function() {
              return this.id;
            }
          }
        }
      };
      data = [
        {
          year: "2012",
          payslips: [
            {
              id: "265",
              PayDate: "10.04.2012",
              NetPayment: "2100.00",
              Payer: "Pullikala Paallikko Oy"
            }, {
              id: "271",
              PayDate: "10.04.2012",
              NetPayment: "2100.00",
              Payer: "Pullikala Paallikko Oy"
            }, {
              id: "270",
              PayDate: "10.04.2012",
              NetPayment: "2100.00",
              Payer: "Pullikala Paallikko Oy"
            }, {
              id: "269",
              PayDate: "10.04.2012",
              NetPayment: "2100.00",
              Payer: "Pullikala Paallikko Oy"
            }, {
              id: "272",
              PayDate: "10.02.2012",
              NetPayment: "2112.00",
              Payer: "Pulli Oy"
            }
          ]
        }
      ];
      expected = $("<div id=\"archive\">\n  <a href=\"http://www.example.com\" class=\"yeartitle\"><span class=\"year\">2012</span></a>\n  <div class=\"payslips\">\n    <a href=\"http://www.example.com\" class=\"payslip\">\n      <span data-id=\"265\" class=\"id\">265</span>\n      <span class=\"date PayDate\">10.04.2012</span>\n      <span class=\"payment\">\n      <span class=\"NetPayment\">2100.00</span>\n      <span>EUR</span></span>\n      <span class=\"payer Payer\">Pullikala Paallikko Oy</span>\n    </a>\n\n    <a href=\"http://www.example.com\" class=\"payslip\">\n      <span data-id=\"271\" class=\"id\">271</span>\n      <span class=\"date PayDate\">10.04.2012</span>\n      <span class=\"payment\">\n      <span class=\"NetPayment\">2100.00</span>\n      <span>EUR</span></span>\n      <span class=\"payer Payer\">Pullikala Paallikko Oy</span>\n    </a>\n\n    <a href=\"http://www.example.com\" class=\"payslip\">\n      <span data-id=\"270\" class=\"id\">270</span>\n      <span class=\"date PayDate\">10.04.2012</span>\n      <span class=\"payment\">\n      <span class=\"NetPayment\">2100.00</span>\n      <span>EUR</span></span>\n      <span class=\"payer Payer\">Pullikala Paallikko Oy</span>\n    </a>\n\n    <a href=\"http://www.example.com\" class=\"payslip\">\n      <span data-id=\"269\" class=\"id\">269</span>\n      <span class=\"date PayDate\">10.04.2012</span>\n      <span class=\"payment\">\n      <span class=\"NetPayment\">2100.00</span>\n      <span>EUR</span></span>\n      <span class=\"payer Payer\">Pullikala Paallikko Oy</span>\n    </a>\n\n    <a href=\"http://www.example.com\" class=\"payslip\">\n      <span data-id=\"272\" class=\"id\">272</span>\n      <span class=\"date PayDate\">10.02.2012</span>\n      <span class=\"payment\">\n      <span class=\"NetPayment\">2112.00</span>\n      <span>EUR</span></span>\n      <span class=\"payer Payer\">Pulli Oy</span>\n    </a>\n  </div>\n</div>");
      template.render(data, directives);
      return expect(template).toBeEqual(expected);
    });
  });

}).call(this);
