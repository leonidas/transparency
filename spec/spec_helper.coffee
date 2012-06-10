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

trim = (text) ->
  text.replace(/\s/g, '').toLowerCase()

isEqualDom = (actual, expected) ->
  unless trim(actual.text()) == trim(expected.text())
    throw new Error "ERROR: '#{actual.text()}' is not equal to '#{expected.text()}'"

  for attribute in expected[0].attributes
    unless actual.attr(attribute.name) == expected.attr(attribute.name)
      throw new Error "ERROR: '#{attribute.name}=\"#{actual.attr(attribute.name)}\"' is not equal to '#{attribute.name}=\"#{expected.attr(attribute.name)}\"'"

  actualChildren = actual.children()
  for child, i in expected.children()
    isEqualDom $(actualChildren[i]), $(child)

beforeEach ->
  this.addMatchers
    toBeEqual: (expected) ->

      message  = '\n' + @actual.html() + '\n' + expected.html()
      @message = () -> message

      try
        isEqualDom @actual, expected
      catch error
        message += '\n' + error.message
        return false

      true
