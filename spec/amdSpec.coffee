define ['dist/transparency'], (t) ->
  describe "Transparency with AMD loader", ->

    it "should bind Transparency to a named variable", ->
      expect(t).toBeDefined()

    it "should define window.Transparency", ->
      expect(window.Transparency).toBeDefined()

    it "should provide a jQuery plugin", ->
      $.fn.render = t.jQueryPlugin
      $('<div><div class="hello"></div></div>').render hello: "World!"
