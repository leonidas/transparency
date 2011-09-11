global.jsdom  = require 'jsdom'
global.window = jsdom.jsdom().createWindow()
global.jQuery = require "jquery"

require "../jquery.transparency.coffee"

describe "Transparency", ->

  beforeEach ->
    this.addMatchers
      htmlToBeEqual: (expected) ->
        #TODO: Refactor to spec_helper.coffee or something
        this.actual = this.actual.replace(/\s\s+/g, '') 
        expected    = expected.replace(/\s\s+/g, '')
        this.actual == expected

  it "should calculate values with directives", ->
    doc = jQuery(
     '<div>
        <div class="person">
          <span class="name"></span>
          <span class="email"></span>
        </div>
      </div>')

    person =
      firstname: 'Jasmine'
      lastname:  'Taylor'
      email:     'jasmine.tailor@example.com'

    directives =
      name: () ->
        "#{this.firstname} #{this.lastname}"

    expected = jQuery(
      '<div>
        <div class="person">
          <span class="name">Jasmine Taylor</span>
          <span class="email">jasmine.tailor@example.com</span>
        </div>
      </div>')

    doc.find('.person').render(person, directives)
    expect(doc.html()).htmlToBeEqual(expected.html())

  it "should handle nested directives", ->
    doc = jQuery(
     '<div>
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
      </div>')

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

    nameDecorator = () -> ("#{this.firstname} #{this.lastname}")
    directives =
      name: nameDecorator
      friends:
        name: nameDecorator


    expected = jQuery(
      '<div>
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
      </div>')

    doc.find('.person').render(person, directives)
    expect(doc.html()).htmlToBeEqual(expected.html())
