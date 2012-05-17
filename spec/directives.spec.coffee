if module?.exports
  require './spec_helper'
  Transparency = require '../src/transparency'

describe "Transparency", ->

  it "should execute directive functions and assign return values to the matching attributes", ->
    template = $ """
      <div class="person">
        <span class="name"></span><span class="email"></span>
      </div>
      """

    person =
      firstname: 'Jasmine'
      lastname:  'Taylor'
      email:     'jasmine.tailor@example.com'

    directives =
      name:
        text: () -> "#{@firstname} #{@lastname}"

    expected = $ """
      <div class="person">
        <span class="name">Jasmine Taylor</span>
        <span class="email">jasmine.tailor@example.com</span>
      </div>
      """

    template.render person, directives
    expect(template.html()).htmlToBeEqual expected.html()

  it "should allow setting html content with directives", ->
    template = $ """
      <div class="person">
        <div class="name"><div>FOOBAR</div></div><span class="email"></span>
      </div>
      """

    person =
      firstname: '<b>Jasmine</b>'
      lastname:  '<i>Taylor</i>'
      email:     'jasmine.tailor@example.com'

    directives =
      name:
        html: () -> "#{@firstname} #{@lastname}"

    expected = $ """
      <div class="person">
        <div class="name"><b>Jasmine</b> <i>Taylor</i><div>FOOBAR</div></div>
        <span class="email">jasmine.tailor@example.com</span>
      </div>
      """

    template.render {firstname: "Hello", lastname: "David"}, directives
    template.render person, directives
    expect(template.html()).htmlToBeEqual expected.html()

  it "should handle nested directives", ->
    template = $ """
      <div class="person">
        <span class="name"></span>
        <span class="email"></span>
        <div class="friends">
          <div class="friend">
            <span class="name"></span>
            <span class="email"></span>
          </div>
        </div>
      </div>
      """

    person =
      firstname:  'Jasmine'
      lastname:   'Taylor'
      email:      'jasmine.taylor@example.com'
      friends:    [
        firstname: 'John'
        lastname:  'Mayer'
        email:     'john.mayer@example.com'
      ,
        firstname: 'Damien'
        lastname:  'Rice'
        email:     'damien.rice@example.com'
      ]

    nameDecorator = (element) -> "#{@firstname} #{@lastname}"
    directives =
      name:
        text: nameDecorator
      friends:
        name:
          text: nameDecorator

    expected = $ """
      <div class="person">
        <span class="name">Jasmine Taylor</span>
        <span class="email">jasmine.taylor@example.com</span>
        <div class="friends">
          <div class="friend">
            <span class="name">John Mayer</span>
            <span class="email">john.mayer@example.com</span>
          </div>
          <div class="friend">
            <span class="name">Damien Rice</span>
            <span class="email">damien.rice@example.com</span>
          </div>
        </div>
      </div>
      """

    template.render person, directives
    expect(template.html()).htmlToBeEqual expected.html()

  it "should restore the original attributes", ->
    template = $ """
      <ul id="persons">
        <li class="person"></li>
      </ul>
      """

    persons = [
      person: "me"
    ,
      person: "you"
    ,
      person: "others"
    ]

    directives =
      person:
        class: (element, i) -> element.className + (if i % 2 then " odd" else " even")

    expected = $ """
      <ul id="persons">
        <li class="person even">me</li>
        <li class="person odd">you</li>
        <li class="person even">others</li>
      </ul>
      """

    template.render persons, directives

    # Render twice to make sure the class names are not duplicated
    template.render persons, directives
    expect(template.html()).htmlToBeEqual expected.html()

  it "should allow directives without a return value", ->
    template = $ """
      <ul id="persons">
        <li class="person"></li>
      </ul>
      """

    persons = [
      person: "me"
    ,
      person: "you"
    ,
      person: "others"
    ]

    directives =
      person:
        html: (elem, i) ->
          elem = jQuery elem
          elem.attr "foobar", "foo"
          elem.text i+1
          return

    expected = $ """
      <ul id="persons">
        <li class="person" foobar="foo">1</li>
        <li class="person" foobar="foo">2</li>
        <li class="person" foobar="foo">3</li>
      </ul>
      """

    template.render persons, directives

    # Render twice to make sure the class names are not duplicated
    template.render persons, directives
    expect(template.html()).htmlToBeEqual expected.html()

  it "should provide current attribute value as a parameter for the directives", ->
    template = $ """
      <div id="template">
        <li class="name">Hello, </li>
      </div>
      """

    data = name: "World"

    directives =
      name:
        text: (elem, i, value) ->
          value + @name + "!"

    expected = $ """
      <div id="template">
        <li class="name">Hello, World!</li>
      </div>
      """

    # Render twice to make sure the text content is not duplicated
    template.render data, directives
    template.render data, directives
    expect(template.html()).htmlToBeEqual expected.html()
