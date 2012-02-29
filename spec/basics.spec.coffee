if typeof module != 'undefined' && module.exports
  require './spec_helper'
  require '../src/transparency'

describe "Transparency", ->

  it "should work with null values", ->
    doc = jQuery(
     '<div>
        <div class="container">
          <div class="hello"></div>
          <div class="goodbye"></div>
        </div>
      </div>')

    data =
      hello:   'Hello'
      goodbye: null

    expected = jQuery(
      '<div>
        <div class="container">
          <div class="hello">Hello</div>
          <div class="goodbye"></div>
        </div>
      </div>')

    doc.find('.container').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())

  it "should assing data values to template via CSS", ->
    doc = jQuery(
     '<div>
        <div class="container">
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
            <div class="greeting"></div>
          </div>
        </div>
      </div>')

    data =
      greeting: 'Hello'
      name:     'World'

    expected = jQuery(
      '<div>
        <div class="container">
          <div class="greeting">Hello<span class="name">World</span>
            <div class="greeting">Hello</div>
          </div>
        </div>
      </div>')

    doc.find('.container').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())

  it "should work with numeric values", ->
    doc = jQuery(
     '<div>
        <div class="container">
          <div class="hello"></div>
          <div class="goodbye"></div>
        </div>
      </div>')

    data =
      hello:   'Hello'
      goodbye: 5

    expected = jQuery(
      '<div>
        <div class="container">
          <div class="hello">Hello</div>
          <div class="goodbye">5</div>
        </div>
      </div>')

    res = doc.find('.container').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())

  it "should match by element id, class, name and data-bind", ->
    doc = jQuery(
     '<div>
        <div class="container">
          <div id="my-id"></div>
          <div class="my-class"></div>
          <span></span>
          <div data-bind="my-data"></div>
        </div>
      </div>')

    data =
      'my-id':   'id-data'
      'my-class': 'class-data'
      span:     'name-data'
      'my-data' : 'data-bind'

    expected = jQuery(
      '<div>
        <div class="container">
          <div id="my-id">id-data</div>
          <div class="my-class">class-data</div>
          <span>name-data</span>
          <div data-bind="my-data">data-bind</div>
        </div>
      </div>')

    res = doc.find('.container').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())
