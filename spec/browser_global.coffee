describe "Transparency without AMD", ->

  it "should export browser global and register jQuery plugin", ->
    expect(window.Transparency).toBeDefined()
    expect(window.jQuery('body').render).toBeDefined()
