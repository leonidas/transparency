if module?.exports
  require './spec_helper'
  Transparency = require '../src/transparency'

describe "Transparency", ->

  it "should execute directive function and assign return value to the matching element attribute", ->
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
      name: text: -> "#{@firstname} #{@lastname}"

    expected = $ """
      <div class="person">
        <span class="name">Jasmine Taylor</span>
        <span class="email">jasmine.tailor@example.com</span>
      </div>
      """

    template.render person, directives
    expect(template).toBeEqual expected

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
      name: html: -> "#{@firstname} #{@lastname}"

    expected = $ """
      <div class="person">
        <div class="name"><b>Jasmine</b> <i>Taylor</i><div>FOOBAR</div></div>
        <span class="email">jasmine.tailor@example.com</span>
      </div>
      """

    template.render {firstname: "Hello", lastname: "David"}, directives
    template.render person, directives
    expect(template).toBeEqual expected

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

    nameDecorator = -> "#{@firstname} #{@lastname}"
    directives =
      name: text: nameDecorator
      friends:
        name: text: nameDecorator

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
    expect(template).toBeEqual expected

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
        class: (params) -> params.value + (if params.index % 2 then " odd" else " even")

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
    expect(template).toBeEqual expected

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
        html: (params) ->
          elem = $ params.element
          elem.attr "foobar", "foo"
          elem.text "" + params.index
          return

    expected = $ """
      <ul id="persons">
        <li class="person" foobar="foo">0</li>
        <li class="person" foobar="foo">1</li>
        <li class="person" foobar="foo">2</li>
      </ul>
      """

    template.render persons, directives

    # Render twice to make sure the class names are not duplicated
    template.render persons, directives
    expect(template).toBeEqual expected

  it "should provide current attribute value as a parameter for the directives", ->
    template = $ """
      <div id="template">
        <div class="name">Hello, <span>Br, Transparency</span></div>
      </div>
      """

    data = me: "World"

    directives =
      name: text: (params) -> params.value + @me + "!"

    expected = $ """
      <div id="template">
        <div class="name">Hello, World!<span>Br, Transparency</span></div>
      </div>
      """

    # Render twice to make sure the text content is not duplicated
    template.render data, directives
    template.render data, directives
    expect(template).toBeEqual expected

  it "should render directives returning empty string, zero and other falsy values", ->
    template = $ """
      <div id="root">
          <span id="d_number">234</span>
          <span id="d_bool">foo</span>
          <span id="d_dec">1.234</span>
          <span id="d_str">abc</span>
      </div>​
      """

    data =
      number: 0
      bool: false
      dec: 0.0
      str: ""

    directives =
      d_number: text: -> @number
      d_bool:   text: -> @bool
      d_dec:    text: -> @dec
      d_str:    text: -> @str

    expected = $ """
     <div id="root">
        <span id="d_number">0</span>
        <span id="d_bool">false</span>
        <span id="d_dec">0</span>
        <span id="d_str"></span>
      </div>​
      """

    template.render data, directives
    expect(template).toBeEqual expected

  it "should throw an error unless directives are syntactically correct", ->
    template = $ """
      <div id="template">
        <div class="name"></div>
      </div>
      """

    data       = name: "World"
    directives = name: -> "#{@name}!"

    expect(-> template.render data, directives)
    .toThrow new Error "Directive syntax is directive[element][attribute] = function(params)"

  it "should use directive return value even if data value is null", ->
    template = $ """
      <div id="template">
        <div class="name"></div>
      </div>
      """

    expected = $ """
      <div id="template">
        <div class="name">Null value</div>
      </div>
      """

    data       = name: null
    directives = name: text: -> "Null value"

    template.render data, directives
    expect(template).toBeEqual expected
