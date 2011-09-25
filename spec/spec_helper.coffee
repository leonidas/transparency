global.jsdom  = require 'jsdom'
global.window = jsdom.jsdom().createWindow()
global.jQuery = require 'jquery'

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
