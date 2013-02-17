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
    unless trim(actual.attr attribute.name) == trim(expected.attr attribute.name)
      throw new Error "ERROR: '#{attribute.name}=\"#{actual.attr(attribute.name)}\"' is not equal to '#{attribute.name}=\"#{expected.attr(attribute.name)}\"'"

  actualChildren   = actual.children()
  expectedChildren = expected.children()

  if expectedChildren.length != actualChildren.length
    throw new Error "Expected children count #{expectedChildren.length} is not equal to actual children count #{actualChildren.length}"

  for child, i in expectedChildren
    isEqualDom $(actualChildren[i]), $(child)

beforeEach ->
  @addMatchers
    toBeEqual: (expected) ->

      message  = '\n' + @actual.html() + '\n' + expected.html()
      @message = () -> message

      try
        isEqualDom @actual, expected
      catch error
        message += '\n' + error.message
        return false

      true

    toBeOnTheSameBallpark: (expected, ballpark) ->
      actual = @actual
      @message = ->
        "Expected #{actual.name} (#{actual.stats.mean} +/- #{actual.stats.moe} to be less than " +
        "#{ballpark} x #{expected.name} (#{expected.stats.mean} +/- #{expected.stats.moe}"

      console.log actual.toString()
      console.log expected.toString()
      actual.stats.mean + actual.stats.moe < ballpark * expected.stats.mean + actual.stats.moe

