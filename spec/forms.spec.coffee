require './spec_helper'
require '../src/jquery.transparency'

describe "Transparency", ->

  it "should render text inputs", ->
    doc = jQuery(
     '<div>
        <form class="user">
          <input type="text" name="user[name]" />
          <input type="password" name="user[password]" />
        </form>
      </div>')

    data =
      user:
        name: "Michael Jackson"
        password: "MySecret42"

    expected = jQuery(
     '<div>
        <form class="user">
          <input type="text" name="user[name]" value="Michael Jackson" />
          <input type="password" name="user[password]" value="MySecret42" />
        </form>
      </div>')

    doc.render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())

  xit "should radio buttons and check boxes", ->
    doc = jQuery(
     '<div>
        <form>
          <label class="desserts">Desserts
            <input type="radio" name="dessert[name]" />
          </label>
          <label class="addons">Add-ons
            <input type="checkbox" name="addon[name]" />
          </label>
        </form>
      </div>')

    data =
      desserts: [
        name: "Coffee"
      ,
        name: "Tea"
      ]
      addons: [
        name: "Milk"
      ,
        name: "Sugar"
      ]

    directives =
      desserts:
        'name@': "foo"

    expected = jQuery(
     '<div>
        <form>
          <label class="desserts">Desserts
            <input type="radio" name="dessert[name]" value="Coffee"/>
            <input type="radio" name="dessert[name]" value="Tea"/>
          </label>
          <label class="addons">Add-ons
            <input type="checkbox" name="addon[name]" value="Milk"/>
            <input type="checkbox" name="addon[name]" value="Sugar"/>
          </label>
        </form>
      </div>')

    doc.find('form').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())

