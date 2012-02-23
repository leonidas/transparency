if typeof module != 'undefined' && module.exports
  require './spec_helper'
  require '../src/jquery.transparency'

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
          <span>blah</span>
        </div>
      </div>')

    data = ["That rules", "Great post!"]

    expected = jQuery(
     '<div>
        <div class="comments">
          <span>That rules</span><span>blah</span><span>Great post!</span><span>blah</span>
        </div>
      </div>')

    doc.find('.comments').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())

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
