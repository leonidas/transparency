if module?.exports
  require './spec_helper'
  Transparency = require '../src/transparency'

describe "Transparency", ->

  it "should calculate values with directives", ->
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
      name: (element) -> "#{@firstname} #{@lastname}"

    expected = $ """
      <div class="person">
        <span class="name">Jasmine Taylor</span>
        <span class="email">jasmine.tailor@example.com</span>
      </div>
      """

    template.render person, directives
    expect(template.html()).htmlToBeEqual expected.html()

  it "should render html content with directives", ->
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
      name: (element) ->
        html: "#{@firstname} #{@lastname}"

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
      name: nameDecorator
      friends:
        name: nameDecorator


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
      person: (element, i) ->
        class: element.className + (if i % 2 then " odd" else " even")

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

  it "should except the element has been manipulated in-place if directive functions return void", ->
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
      person: (elem, i) ->
        elem = jQuery elem
        elem.attr("foobar", "foo")
        elem.text("daa")
        return

    expected = $ """
      <ul id="persons">
        <li class="person" foobar="foo">daa</li>
        <li class="person" foobar="foo">daa</li>
        <li class="person" foobar="foo">daa</li>
      </ul>
      """

    template.render persons, directives

    # Render twice to make sure the class names are not duplicated
    template.render persons, directives
    expect(template.html()).htmlToBeEqual expected.html()
