global.jsdom  = require 'jsdom'
global.window = jsdom.jsdom().createWindow()
global.jQuery = require "jquery"

require "../jquery.transparency.coffee"

describe "Transparency", ->

  beforeEach ->
    this.addMatchers
      htmlToBeEqual: (expected) ->
        #TODO: Refactor to spec_helper.coffee or something
        formatHtml = (html) ->
          html.replace(/\s\s+/g, '').replace(/></g, '>\n<').split('\n')

        actual   = formatHtml(this.actual)
        expected = formatHtml(expected)
        message  = ""

        result = true
        row    = 0
        while row < Math.min(actual.length, expected.length)
          if actual[row] != expected[row]
            result  = false
            message = "Expected row #{row + 1} to be equal:\nActual:  #{actual[row]}\nExpected:#{expected[row]}"
            break
          row += 1

        this.message = () ->
          message

        result


  it "should work with null values", ->
    doc = jQuery(
     '<div>
        <div class="content">
        </div>
        <div class="template">
          <div class="container"
            <div class="hello"></div>
            <div class="goodbye"></div>
          </div>
        </div>
      </div>')

    data =
      hello:   'Hello'
      goodbye: null

    expected = jQuery(
      '<div>
        <div class="content"
          <div class="container">
            <div class="hello">Hello</div>
            <div class="goodbye"></div>
          </div>
        </div>
        <div class="template">
          <div class="container">
            <div class="hello"></div>
            <div class="goodbye"></div>
          </div>
        </div>
      </div>')

  it "should assing data values to template", ->
    doc = jQuery(
     '<div>
        <div class="content">
        </div>
        <div class="template">
          <div class="container"
            <div class="hello"></div>
            <div class="goodbye"></div>
          </div>
        </div>
      </div>')

    data =
      hello:   'Hello'
      goodbye: 'Goodbye!'

    expected = jQuery(
      '<div>
        <div class="content"
          <div class="container">
            <div class="hello">Hello</div>
            <div class="goodbye">Goodbye!</div>
          </div>
        </div>
        <div class="template">
          <div class="container">
            <div class="hello"></div>
            <div class="goodbye"></div>
          </div>
        </div>
      </div>')

    doc.find('.template .container').clone().render(data).appendTo(doc.find('.content'))
    expect(doc.html()).htmlToBeEqual(expected.html())

    doc.find('.content').empty().append(doc.find('.template .container').clone())
    doc.find('.content .container').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())

  it "should handle nested templates", ->
    doc = jQuery(
     '<div>
        <div class="container">
          <div class="greeting">
            <span class="name"></span>
            <div class="greeting">
            </div>
          </div>
        </div>
      </div>')

    data =
      greeting: 'Hello'
      name:     ' World, '

    expected = jQuery(
      '<div>
        <div class="container">
          <div class="greeting">Hello
            <span class="name"> World, </span>
            <div class="greeting">Hello
            </div>
          </div>
        </div>
      </div>')

    doc.find('.container').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())
