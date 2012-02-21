jsdom           = require('jsdom/lib/jsdom').jsdom
global.document = jsdom "<html><head></head><body>hello world</body></html>" #, null, features: {QuerySelector: true}
global.window   = document.createWindow()
jsdom           = require 'jsdom'
global.jQuery   = require 'jquery'

beforeEach ->
  this.addMatchers
    htmlToBeEqual: (expected) ->

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
