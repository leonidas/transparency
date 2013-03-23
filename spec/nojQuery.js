(function() {
  describe("Transparency without jQuery", function() {
    return it("should export browser global and register jQuery plugin", function() {
      return expect(window.Transparency).toBeDefined();
    });
  });

}).call(this);
