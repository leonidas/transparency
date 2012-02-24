if typeof module != 'undefined' && module.exports
  require './spec_helper'
  require '../src/transparency'

describe "Transparency", ->

  it "should handle list of objects", ->
    doc = jQuery(
     '<div>
        <div class="comments">
          <div class="comment">
            <span class="name"></span><span class="text"></span></div>
        </div>
      </div>')

    data = [
      name: 'John'
      text: 'That rules'
    ,
      name: 'Arnold'
      text: 'Great post!'
    ]

    expected = jQuery(
     '<div>
        <div class="comments">
          <div class="comment">
            <span class="name">John</span><span class="text">That rules</span>
          </div><div class="comment">
            <span class="name">Arnold</span><span class="text">Great post!</span>
          </div>
        </div>
      </div>')

    doc.find('.comments').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())
    expect(doc.find('.comment').get(0).transparency.model).toEqual(data[0])
    expectModelObjects doc.find('.comment'), data

  it "should handle empty lists", ->
    doc = jQuery(
     '<div>
        <div class="comments">
          <div class="comment">
            <span class="name"></span>
            <span class="text"></span>
          </div>
        </div>
      </div>')

    data = []

    expected = jQuery(
     '<div>
        <div class="comments">
        </div>
      </div>')

    doc.find('.comments').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())

  it "should render list containing simple values", ->
    doc = jQuery(
     '<div>
        <div class="comments">
          <span></span>
          <label>blah</label>
        </div>
      </div>')

    data = ["That rules", "Great post!"]

    expected = jQuery(
     '<div>
        <div class="comments">
          <span>That rules</span><label>blah</label><span>Great post!</span><label>blah</label>
        </div>
      </div>')

    doc.find('.comments').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())
    expectModelObjects doc.find('span'), data

  it "should place simple value into element with listElement class if found", ->
    doc = jQuery(
     '<div>
        <div class="comments">
          <label>comment</label><span class="listElement"></span>
        </div>
      </div>')

    data = ["That rules", "Great post!"]

    expected = jQuery(
     '<div>
        <div class="comments">
          <label>comment</label><span class="listElement">That rules</span>
          <label>comment</label><span class="listElement">Great post!</span>
        </div>
      </div>')

    doc.find('.comments').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())
    expectModelObjects doc.find('.listElement'), data

  it "should not fail when there's no child node in the simple list template", ->
    doc = jQuery(
     '<div>
        <div class="comments">
        </div>
      </div>')

    data = ["That rules", "Great post!"]

    expected = jQuery(
     '<div>
        <div class="comments">
        </div>
      </div>')

    doc.find('.comments').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())

expectModelObjects = (elements, data) ->
  for object, i in data
    expect(elements.get(i).transparency.model).toEqual(object)
