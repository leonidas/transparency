if typeof module != 'undefined' && module.exports
  jsdom           = require('jsdom/lib/jsdom').jsdom
  global.document = jsdom "<html><head></head><body>hello world</body></html>"
  global.window   = document.createWindow()
  jsdom           = require 'jsdom'
  global.jQuery   = require 'jquery'

beforeEach ->
  this.addMatchers
    htmlToBeEqual: (expected) ->

      formatHtml = (html) ->
        html.replace(/\s/g, '').toLowerCase()

      actual   = formatHtml(@actual)
      expected = formatHtml(expected)

      this.message = () ->
        actual + '\n\n' + expected

      actual == expected