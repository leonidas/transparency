(function() {

  define(['dist/transparency'], function(t) {
    return describe("Transparency with AMD loader", function() {
      it("should bind Transparency to a named variable", function() {
        return expect(t).toBeDefined();
      });
      it("should define window.Transparency", function() {
        return expect(window.Transparency).toBeDefined();
      });
      return it("should provide a jQuery plugin", function() {
        $.fn.render = t.jQueryPlugin;
        return $('<div><div class="hello"></div></div>').render({
          hello: "World!"
        });
      });
    });
  });

}).call(this);
