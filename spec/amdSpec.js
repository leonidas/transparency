(function() {
  define(['dist/transparency'], function(t) {
    return describe("Transparency with AMD loader", function() {
      it("should bind Transparency to a named variable", function() {
        return expect(t).toBeDefined();
      });
      it("should define window.Transparency", function() {
        return expect(window.Transparency).toBeDefined();
      });
      it("should provide a jQuery plugin", function() {
        $.fn.render = t.jQueryPlugin;
        return $('<div><div class="hello"></div></div>').render({
          hello: "World!"
        });
      });
      return it("should work even if the $ is not in the global namespace", function() {
        $.noConflict();
        jQuery.fn.render = t.jQueryPlugin;
        jQuery('<p><span class="hello"></span></p>').render({
          hello: "World!"
        });
        return window.$ = jQuery;
      });
    });
  });

}).call(this);
