if typeof module != 'undefined' && module.exports
  require './spec_helper'
  Transparency = require '../src/transparency'

describe "Transparency", ->

  it "should render objects to form input elements", ->
    doc = document.createElement 'div'
    doc.innerHTML = '
        <form id="edit">
          <input name="name" type="text" />
          <input name="job" type="text" />
        </form>'

    data = [
      name: 'John'
      job: 'Milkman'
    ]

    expected = jQuery(
     '<div>
        <form id="edit">
          <input name="name" type="text" value="John"/>
          <input name="job" type="text" value="Milkman"/>
        </form>
      </div>')

    Transparency.render doc, data
    expect(doc.innerHTML).htmlToBeEqual(expected.html())

