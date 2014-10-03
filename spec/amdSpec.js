(function() {
  require.config({
    baseUrl: '..'
  });

  describe("Transparency with AMD loader", function() {
    it("should bind Transparency to a named variable", function(done) {
      return require(['dist/transparency'], function(t) {
        expect(t).toBeDefined();
        return done();
      });
    });
    it("should define window.Transparency", function(done) {
      return require(['dist/transparency'], function(t) {
        expect(window.Transparency).toBeDefined();
        return done();
      });
    });
    it("should provide a jQuery plugin", function(done) {
      return require(['dist/transparency'], function(t) {
        $.fn.render = t.jQueryPlugin;
        $('<div><div class="hello"></div></div>').render({
          hello: "World!"
        });
        return done();
      });
    });
    return it("should work even if the $ is not in the global namespace", function(done) {
      return require(['dist/transparency'], function(t) {
        $.noConflict();
        jQuery.fn.render = t.jQueryPlugin;
        jQuery('<p><span class="hello"></span></p>').render({
          hello: "World!"
        });
        window.$ = jQuery;
        return done();
      });
    });
  });

}).call(this);
