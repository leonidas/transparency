require './spec_helper'
require '../jquery.transparency'

describe "Transparency", ->

  it "should handle list of objects", ->
    doc = jQuery(
     '<div>
        <div class="comments">
          <div class="comment">
            <span class="name"></span>
            <span class="text"></span>
          </div>
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
            <span class="name">John</span>
            <span class="text">That rules</span>
          </div><div class="comment">
            <span class="name">Arnold</span>
            <span class="text">Great post!</span>
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
