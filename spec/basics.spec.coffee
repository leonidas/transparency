require './spec_helper'
require '../jquery.transparency.coffee'

describe "Transparency", ->

  it "should work with null values", ->
    doc = jQuery(
     '<div>
        <div class="container"
          <div class="hello"></div>
          <div class="goodbye"></div>
        </div>
      </div>')

    data =
      hello:   'Hello'
      goodbye: null

    expected = jQuery(
      '<div>
        <div class="container"
          <div class="hello">Hello</div>
          <div class="goodbye"></div>
        </div>
      </div>')

    res = doc.find('.container').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())
    #expect(res.html()).htmlToBeEqual(expected.html())

  it "should assing data values to template", ->
    doc = jQuery(
     '<div>
        <div class="container"
          <div class="hello"></div>
          <div class="goodbye"></div>
        </div>
      </div>')

    data =
      hello:   'Hello'
      goodbye: 'Goodbye!'

    expected = jQuery(
      '<div>
        <div class="container">
          <div class="hello">Hello</div>
          <div class="goodbye">Goodbye!</div>
        </div>
      </div>')

    doc.find('.container').render(data)
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
    #expect(result).htmlToBeEqual(expected.html())
