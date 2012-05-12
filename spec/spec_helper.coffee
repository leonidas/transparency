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

      actual   = formatHtml(@actual)
      expected = formatHtml(expected)

      this.message = () ->
        actual + '\n\n' + expected

      actual == expected