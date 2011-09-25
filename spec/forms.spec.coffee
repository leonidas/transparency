require './spec_helper'
require '../jquery.transparency.coffee'

describe "Transparency", ->

  it "should render input elements", ->
    doc = jQuery(
     '<div>
        <form class="person">
          <label>Name
            <input type="text" name="name" />
            <input type="password" name="password" />
          </label>
        </form>
      </div>')

    data =
      name: "Michael Jackson"
      password: "MySecret42"

    expected = jQuery(
     '<div>
        <form class="person">
          <label>Name
            <input type="text" name="name" value="Michael Jackson" />
            <input type="password" name="password" value="MySecret42" />
          </label>
        </form>
      </div>')

    doc.find('.person').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())

  xit "should select elements", ->
    doc = jQuery(
     '<div>
        <form class="hotel_reservation">
          <label>Name
            <input type="text" name="name" />
          </label>
          <label>Room type
            <select class="room_types">
              <option class="name"></option>
            </select>
          </label>
        </form>
      </div>')

    data =
      name: "Michael Jackson"
      room_types: [
          name: "Single"
          id:   "1"
        ,
          name: "Double"
          id:   "2"
        ,
          name: "King Size"
          id:   "3"
          selected: "true"
        ]

    directives =
      name: ''
      'name_input@value': -> @name
      room_types:
        'name@value':    -> @id
        'name@selected': -> @selected

    expected = jQuery(
     '<div>
        <form class="hotel_reservation">
          <label>Name
            <input type="text" name="name" value="Michael Jackson"/>
          </label>
          <label>Room type
            <select class="room_types">
              <option class="name" value="1">Single</option>
              <option class="name" value="2">Double</option>
              <option class="name" value="3" selected="selected">King Size</option>
            </select>
          </label>
        </form>
      </div>')

    doc.find('.hotel_reservation').render(data, directives)
    expect(doc.html()).htmlToBeEqual(expected.html())
