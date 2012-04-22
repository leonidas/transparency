if typeof module != 'undefined' && module.exports
  require './spec_helper'
  window.Transparency = require('../src/transparency')

describe "Transparency", ->

  it "should handle object-like directive with html() function", ->
    doc = jQuery(
     '<div>
        <ul id="persons">
          <li class="person"></li>
        </ul>
      </div>')

    persons = [
      person: "me"
    ]

    directives =
      person:
        html: ->
          return "<span>Foobar</span>"

    expected = jQuery(
      '<div>
        <ul id="persons">
          <li class="person"><span>Foobar</span></li>
        </ul>
      </div>')

    doc.find('#persons').render(persons, directives)

    expect(doc.html()).htmlToBeEqual(expected.html())    

  it "should handle object-like directive with text() function", ->
    doc = jQuery(
     '<div>
        <ul id="persons">
          <li class="person"></li>
        </ul>
      </div>')

    persons = [
      person: "me"
    ]

    directives =
      person:
        text: ->
          return "Foobar >"

    expected = jQuery(
      '<div>
        <ul id="persons">
          <li class="person">Foobar &gt;</li>
        </ul>
      </div>')

    doc.find('#persons').render(persons, directives)

    # Render twice to make sure the class names are not duplicated
    doc.find('#persons').render(persons, directives)
    expect(doc.html()).htmlToBeEqual(expected.html())        

  it "should handle object-like directives' attribute functions which manipulate input value", ->
    doc = jQuery(
     '<div>
        <ul id="persons">
          <li class="person"></li>
        </ul>
      </div>')

    persons = [
      person: "me"
    ]

    directives =
      person:
        class: (value) ->
          return value + "-x"
        text: ->
          return "Mikko"

    expected = jQuery(
      '<div>
        <ul id="persons">
          <li class="person-x">Mikko</li>
        </ul>
      </div>')

    doc.find('#persons').render(persons, directives)

    expect(doc.html()).htmlToBeEqual(expected.html())    


  # This case is not correctly handled as 
  # we need to somehow make object directives understand lists better
  xit "should handle complex object-like nested directives", ->
    doc = jQuery(
     '<div>
        <ul id="persons">
          <li class="person">
              <p class="name"></p>
              <a class="email"></a>
          </li>
        </ul>
      </div>')

    persons = [
      person : [
        { 
          id : 9000
          name : "Mikko"
          email : "xmikko@opensourcehacker.com"
        },
        {
          id : 9001
          name : "Mikko 2"
          email : "xmikko@opensourcehacker.com2"
        }
      ]
    ]

    directives =
      person:

        # XXX: Need to solve how to declare "id" function here
        # Set id on the main element. Currently we do in-place manipulation
        id: ->          
          return this.id

        # Recurse to a child element named "name"
        name:
          text: ->
            return this.name

        # Recurse to a child element named "email"
        email:
          text: ->
            return this.email

          href: (value) ->
            return "mailto:" + this.email

    expected = jQuery(
      '<div>
        <ul id="persons">
          <li class="person" id="9000">
              <p class="name">Mikko</p>
              <a class="email" href="mailto:xmikko@opensourcehacker.com">xmikko@opensourcehacker.com</a>
          </li>

          <li class="person" id="9001" >
              <p class="name">Mikko 2</p>
              <a class="email" href="mailto:xmikko@opensourcehacker.com">xmikko@opensourcehacker.com2</a>
          </li>          
        </ul>
      </div>')

    doc.find('#persons').render(persons, directives)

    expect(doc.html()).htmlToBeEqual(expected.html())          