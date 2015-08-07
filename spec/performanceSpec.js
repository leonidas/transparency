(function() {
  describe("Transparency performance", function() {
    this.timeout(30000);
    describe("with cached templates", function() {
      describe("with one todo item", function() {
        return it("should be on the same ballpark with Handlebars", function(done) {
          var handlebars, transparency;
          transparency = new Benchmark('transparency - cached template, one todo', {
            setup: function() {
              var data, i, index, template;
              template = $('<div class="template"><div class="todo"></div></div>')[0];
              index = 0;
              data = (function() {
                var k, ref, results;
                results = [];
                for (i = k = 1, ref = this.count; 1 <= ref ? k <= ref : k >= ref; i = 1 <= ref ? ++k : --k) {
                  results.push({
                    todo: Math.random()
                  });
                }
                return results;
              }).call(this);
              Transparency.render(template, {
                todo: Math.random()
              });
            },
            fn: function() {
              Transparency.render(template, data[index++]);
            }
          });
          handlebars = new Benchmark('handlebars - compiled and cached template, one todo', {
            setup: function() {
              var data, i, index, parser, template;
              parser = $('<div></div>')[0];
              template = Handlebars.compile('<div class="template"><div class="todo">{{todo}}</div></div>');
              index = 0;
              data = (function() {
                var k, ref, results;
                results = [];
                for (i = k = 1, ref = this.count; 1 <= ref ? k <= ref : k >= ref; i = 1 <= ref ? ++k : --k) {
                  results.push({
                    todo: Math.random()
                  });
                }
                return results;
              }).call(this);
            },
            fn: function() {
              parser.innerHTML = template(data[index++]);
            }
          });
          return new Benchmark.Suite().add(transparency).add(handlebars).on('complete', function() {
            expect(this[0]).toBeOnTheSameBallpark(this[1], 5);
            return done();
          }).run();
        });
      });
      return describe("with hundred todo items", function() {
        return it("should be on the same ballpark with Handlebars", function() {
          var handlebars, transparency;
          transparency = new Benchmark('transparency - cached template, 100 todos', {
            setup: function() {
              var data, i, index, j, template;
              template = $('<div class="template"><div class="todo"></div></div>')[0];
              index = 0;
              data = (function() {
                var k, ref, results;
                results = [];
                for (i = k = 1, ref = this.count; 1 <= ref ? k <= ref : k >= ref; i = 1 <= ref ? ++k : --k) {
                  results.push((function() {
                    var l, results1;
                    results1 = [];
                    for (j = l = 1; l <= 100; j = ++l) {
                      results1.push({
                        todo: Math.random()
                      });
                    }
                    return results1;
                  })());
                }
                return results;
              }).call(this);
              Transparency.render(template, (function() {
                var k, results;
                results = [];
                for (j = k = 1; k <= 100; j = ++k) {
                  results.push({
                    todo: Math.random()
                  });
                }
                return results;
              })());
            },
            fn: function() {
              Transparency.render(template, data[index++]);
            }
          });
          handlebars = new Benchmark('handlebars - compiled and cached template, 100 todos', {
            setup: function() {
              var data, i, index, j, parser, template;
              parser = $('<div></div>')[0];
              template = Handlebars.compile('<div class="template">{{#each this}}<div class="todo">{{todo}}</div>{{/each}}</div>');
              index = 0;
              data = (function() {
                var k, ref, results;
                results = [];
                for (i = k = 1, ref = this.count; 1 <= ref ? k <= ref : k >= ref; i = 1 <= ref ? ++k : --k) {
                  results.push((function() {
                    var l, results1;
                    results1 = [];
                    for (j = l = 1; l <= 100; j = ++l) {
                      results1.push({
                        todo: Math.random()
                      });
                    }
                    return results1;
                  })());
                }
                return results;
              }).call(this);
            },
            fn: function() {
              parser.innerHTML = template(data[index++]);
            }
          });
          return new Benchmark.Suite().add(transparency).add(handlebars).on('complete', function() {
            return expect(this[0]).toBeOnTheSameBallpark(this[1], 5);
          }).run();
        });
      });
    });
    return describe("on first render call", function() {
      describe("with one todo item", function() {
        return it("should be on the same ballpark with Handlebars", function() {
          var handlebars, transparency;
          transparency = new Benchmark('transparency - unused template, one todo', {
            setup: function() {
              var data, i, index, template;
              template = (function() {
                var k, ref, results;
                results = [];
                for (i = k = 1, ref = this.count; 1 <= ref ? k <= ref : k >= ref; i = 1 <= ref ? ++k : --k) {
                  results.push($('<div class="template"><div class="todo"></div></div>')[0]);
                }
                return results;
              }).call(this);
              index = 0;
              data = (function() {
                var k, ref, results;
                results = [];
                for (i = k = 1, ref = this.count; 1 <= ref ? k <= ref : k >= ref; i = 1 <= ref ? ++k : --k) {
                  results.push({
                    todo: Math.random()
                  });
                }
                return results;
              }).call(this);
            },
            fn: function() {
              Transparency.render(template[index], data[index++]);
            }
          });
          handlebars = new Benchmark('handlebars - unused and compiled template, one todo', {
            setup: function() {
              var data, i, index, parser, template;
              parser = (function() {
                var k, ref, results;
                results = [];
                for (i = k = 1, ref = this.count; 1 <= ref ? k <= ref : k >= ref; i = 1 <= ref ? ++k : --k) {
                  results.push($('<div></div>')[0]);
                }
                return results;
              }).call(this);
              template = (function() {
                var k, ref, results;
                results = [];
                for (i = k = 1, ref = this.count; 1 <= ref ? k <= ref : k >= ref; i = 1 <= ref ? ++k : --k) {
                  results.push(Handlebars.compile('<div class="template"><div class="todo">{{todo}}</div></div>'));
                }
                return results;
              }).call(this);
              index = 0;
              data = (function() {
                var k, ref, results;
                results = [];
                for (i = k = 1, ref = this.count; 1 <= ref ? k <= ref : k >= ref; i = 1 <= ref ? ++k : --k) {
                  results.push({
                    todo: Math.random()
                  });
                }
                return results;
              }).call(this);
            },
            fn: function() {
              parser[index].innerHTML = template[index](data[index++]);
            }
          });
          return new Benchmark.Suite().add(transparency).add(handlebars).on('complete', function() {
            return expect(this[0]).toBeOnTheSameBallpark(this[1], 5);
          }).run();
        });
      });
      return describe("with hundred todo items", function() {
        return it("should be on the same ballpark with Handlebars", function() {
          var handlebars, transparency;
          transparency = new Benchmark('transparency - unused template, 100 todos', {
            setup: function() {
              var data, i, index, j, template;
              template = (function() {
                var k, ref, results;
                results = [];
                for (i = k = 1, ref = this.count; 1 <= ref ? k <= ref : k >= ref; i = 1 <= ref ? ++k : --k) {
                  results.push($('<div class="template"><div class="todo"></div></div>')[0]);
                }
                return results;
              }).call(this);
              index = 0;
              data = (function() {
                var k, ref, results;
                results = [];
                for (i = k = 1, ref = this.count; 1 <= ref ? k <= ref : k >= ref; i = 1 <= ref ? ++k : --k) {
                  results.push((function() {
                    var l, results1;
                    results1 = [];
                    for (j = l = 1; l <= 100; j = ++l) {
                      results1.push({
                        todo: Math.random()
                      });
                    }
                    return results1;
                  })());
                }
                return results;
              }).call(this);
            },
            fn: function() {
              Transparency.render(template[index], data[index++]);
            }
          });
          handlebars = new Benchmark('handlebars - unused and compiled template, 100 todos', {
            setup: function() {
              var data, i, index, j, parser, template;
              parser = (function() {
                var k, ref, results;
                results = [];
                for (i = k = 1, ref = this.count; 1 <= ref ? k <= ref : k >= ref; i = 1 <= ref ? ++k : --k) {
                  results.push($('<div></div>')[0]);
                }
                return results;
              }).call(this);
              template = (function() {
                var k, ref, results;
                results = [];
                for (i = k = 1, ref = this.count; 1 <= ref ? k <= ref : k >= ref; i = 1 <= ref ? ++k : --k) {
                  results.push(Handlebars.compile('<div class="template">{{#each this}}<div class="todo">{{todo}}</div>{{/each}}</div>'));
                }
                return results;
              }).call(this);
              index = 0;
              data = (function() {
                var k, ref, results;
                results = [];
                for (i = k = 1, ref = this.count; 1 <= ref ? k <= ref : k >= ref; i = 1 <= ref ? ++k : --k) {
                  results.push((function() {
                    var l, results1;
                    results1 = [];
                    for (j = l = 1; l <= 100; j = ++l) {
                      results1.push({
                        todo: Math.random()
                      });
                    }
                    return results1;
                  })());
                }
                return results;
              }).call(this);
            },
            fn: function() {
              parser[index].innerHTML = template[index](data[index++]);
            }
          });
          return new Benchmark.Suite().add(transparency).add(handlebars).on('complete', function() {
            return expect(this[0]).toBeOnTheSameBallpark(this[1], 7);
          }).run();
        });
      });
    });
  });

}).call(this);
