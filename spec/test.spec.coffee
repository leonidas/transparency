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
        <div class="name">aa</div>
      </div>')
    template.appendTo('body')

    data =
      name:     'World!'
      greeting: 'Hello '

    result = jQuery(
      '<div class="container">
        <div class="greeting">Hello </div>
        <div class="name">World!</div>
      </div>')

    res = template.render(data)
    jasmine.log res.data()
    expect(res.html()).toEqual(result.html())
