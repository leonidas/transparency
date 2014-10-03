{jsdom}  = require "jsdom"
{expect} = require "./assert"

Transparency = require "../index"

describe "Transparency", ->

  it "should work on node.js", (done) ->

    jsdom.env "", [], (errors, {document}) ->

      template = document.createElement 'div'
      template.innerHTML =
        """
        <div class="container">
          <div class="hello"></div>
        </div>
        """

      data = hello: 'Hello'

      expected = document.createElement 'div'
      expected.innerHTML =
        """
        <div class="container">
          <div class="hello">Hello</div>
        </div>
        """

      Transparency.render template, data
      expect(template.innerHTML).toEqual expected.innerHTML
      done()
