if typeof module != 'undefined' && module.exports
  require './spec_helper'
  Transparency = require '../src/transparency'

describe "Transparency", ->

  it "should render values to form inputs and textarea elements", ->
    doc = document.createElement 'form'
    doc.innerHTML =
      '<input name="name" type="text" />
      <input name="job" type="text" />
      <textarea name="resume"></textarea>'

    data =
      name: 'John'
      job: 'Milkman'
      resume: "Jack of all trades"

    expected = document.createElement 'form'
    expected.innerHTML =
      '<input name="name" type="text" value="John"/>
      <input name="job" type="text" value="Milkman"/>
      <textarea name="resume">Jack of all trades</textarea>'

    Transparency.render doc, data
    expect(doc.innerHTML).htmlToBeEqual(expected.innerHTML)

  it "should render values to option elements", ->
    doc = document.createElement 'form'
    doc.innerHTML = '
      <select id="states">
        <option class="state"></option>
      </select>'

    data =
      states: [
        id: 1
        state: 'Alabama'
      ,
        id: 2
        state: 'Alaska'
      ,
        id: 3
        state: 'Arizona'
      ]

    directives =
      states:
        'state@value': () -> @id

    expected = jQuery(
     '<form
        <select id="states">
          <option class="state" value="1">Alabama</option>
          <option class="state" value="2">Alaska</option>
          <option class="state" value="3">Arizona</option>
        </select>
      </form>')

    Transparency.render doc, data, directives
    expect(doc.innerHTML).htmlToBeEqual(expected.html())
