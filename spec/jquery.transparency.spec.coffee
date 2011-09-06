# fake browser window
global.window = require("jsdom").jsdom().createWindow()
global.jQuery = require "jquery"

_ = require "underscore"
require "../jquery.transparency.coffee"

describe "Transparency", ->

  it "should assing data values to template", ->
    template = jQuery(
     '<div class="container">
        <div class="greeting"></div>
        <div class="name"></div>
      </div>')
    template.appendTo('body')

    data =
      greeting: 'Hello '
      name:     'World!'

    result = jQuery(
      '<div class="container">
        <div class="greeting">Hello </div>
        <div class="name">World!</div>
      </div>')

    expect(template.render(data).html()).toEqual(result.html())

  it "should handle nested templates", ->
    template = jQuery(
     '<div class="container">
        <div class="greeting">
          <span class="name"></span>
        </div>
      </div>')

    data =
      greeting: 'Hello '
      name:     'World!'

    result = jQuery(
      '<div class="container">
        <div class="greeting">Hello 
          <span class="name">World!</span>
        </div>
      </div>')

    expect(template.render(data).html()).toEqual(result.html())

  it "should handle attribute assignment", ->
    template = jQuery(
     '<div class="container">
        <a class="greeting" href="#"></a>
      </div>')

    data =
      greeting:         'Hello World'
      'greeting@href':  'http://world'

    result = jQuery(
      '<div class="container">
        <a class="greeting" href="http://world">Hello World</a>
      </div>')

    expect(template.render(data).html()).toEqual(result.html())