require './specHelper'

{jsdom}      = require "jsdom"
global.$     = require "jquery"
Transparency = require "../index"
$.fn.render  = Transparency.jQueryPlugin

describe "Transparency", ->

  it "should work on node.js", ->
    template = $ """
      <div class="container">
        <div class="hello"></div>
      </div>
      """

    data = hello: 'Hello'

    expected = $ """
      <div class="container">
        <div class="hello">Hello</div>
      </div>
      """

    template.render data
    expect(template).toBeEqual expected
