require './spec_helper'
require '../jquery.transparency.coffee'

describe "Transparency", ->

  it "cache templates", ->
    doc = jQuery(
     '<div>
        <div class="container">
          <div>
            <span class="hello"></span>
            <span class="world"></span>
          </div>
        </div>
      </div>')

    data = [
      hello: "Hello"
      world: "World!"
    ,
      hello: "Goodbye"
      world: "Canada!"
    ]

    expected = jQuery(
     '<div>
        <div class="container">
          <div>
            <span class="hello">Hello</span>
            <span class="world">World!</span>
          </div>
          <div>
            <span class="hello">Goodbye</span>
            <span class="world">Canada!</span>
          </div>
        </div>
      </div>')

    doc.find('.container').render(data)
    doc.find('.container').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())
