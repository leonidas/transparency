if module?.exports
  global.document = require('jsdom/lib/jsdom').jsdom """
    <!DOCTYPE html>
    <html>
      <head>
      </head>
      <body>
      </body>
    </html>
    """

  global.window = document.createWindow()
  global.jQuery = global.$ = require('jquery').create window

beforeEach ->
  this.addMatchers
    htmlToBeEqual: (expected) ->

      formatHtml = (html) ->
        html.replace(/\s/g, '').toLowerCase()

      actual   = formatHtml(@actual.html())
      expected = formatHtml(expected.html())

      this.message = () ->
        '\n' + actual + '\n' + expected

      actual == expected