define ['jquery', '../dist/transparency'], ($, t) ->
  describe "Transparency with AMD loader", ->

    it "should bind Transparency to a named variable", ->
      expect(t).toBeDefined()

    it "should not define window.Transparency", ->
      expect(window.Transparency).not.toBeDefined()

    it "should provide a jQuery plugin", ->
      $.fn.render = t.jQueryPlugin
      $('<div><div class="hello"></div></div>').render(hello: "World!")
