(function() {
  describe("Transparency without AMD", function() {
    return it("should export browser global and register jQuery plugin", function() {
      expect(window.Transparency).toBeDefined();
      return expect(window.jQuery('body').render).toBeDefined();
    });
  });

}).call(this);
