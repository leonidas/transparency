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