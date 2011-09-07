global.jsdom  = require 'jsdom'
global.window = jsdom.jsdom().createWindow()
global.jQuery = require "jquery"

require "../jquery.transparency.coffee"

describe "Transparency", ->

  beforeEach ->
    this.addMatchers
      htmlToBeEqual: (expected) ->
        #TODO: Refactor to spec_helper.coffee or something
        this.actual = this.actual.replace(/\s\s+/g, '') 
        expected    = expected.replace(/\s\s+/g, '')
        this.actual == expected


  it "should assing data values to template", ->
    doc = jQuery(
     '<div>
        <div class="container">
          <div class="greeting"></div>
          <div class="name"></div>
        </div>
      </div>')

    data =
      greeting: 'Hello '
      name:     'World!'

    expected = jQuery(
      '<div>
        <div class="container">
          <div class="greeting">Hello </div>
          <div class="name">World!</div>
        </div>
      </div>')

    doc.find('.container').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())

  it "should handle nested templates", ->
    doc = jQuery(
     '<div>
        <div class="container">
          <div class="greeting">
            <span class="name"></span>
          </div>
        </div>
      </div>')

    data =
      greeting: 'Hello '
      name:     'World!'

    expected = jQuery(
      '<div>
        <div class="container">
          <div class="greeting">Hello 
            <span class="name">World!</span>
          </div>
        </div>
      </div>')

    doc.find('.container').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())

  it "should handle attribute assignment", ->
    doc = jQuery(
     '<div>
        <div class="container">
          <a class="greeting" href="#"></a>
        </div>
      </div>')

    data =
      "greeting":      "Hello World"
      "greeting@href": "http://world"

    expected = jQuery(
      '<div>
        <div class="container">
          <a class="greeting" href="http://world">Hello World</a>
        </div>
      </div>')

    doc.find('.container').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())