describe "Transparency without jQuery", ->

  it "should export browser global and register jQuery plugin", ->
    expect(window.Transparency).toBeDefined()
