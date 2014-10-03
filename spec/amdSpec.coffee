require.config baseUrl: '..'

describe "Transparency with AMD loader", ->

  it "should bind Transparency to a named variable", (done) ->
    require ['dist/transparency'], (t) ->
      expect(t).toBeDefined()
      done()

  it "should define window.Transparency", (done) ->
    require ['dist/transparency'], (t) ->
      expect(window.Transparency).toBeDefined()
      done()

  it "should provide a jQuery plugin", (done) ->
    require ['dist/transparency'], (t) ->
      $.fn.render = t.jQueryPlugin
      $('<div><div class="hello"></div></div>').render hello: "World!"
      done()

  it "should work even if the $ is not in the global namespace", (done) ->
    require ['dist/transparency'], (t) ->
      $.noConflict();
      jQuery.fn.render = t.jQueryPlugin
      jQuery('<p><span class="hello"></span></p>').render hello: "World!"
      window.$ = jQuery
      done()
