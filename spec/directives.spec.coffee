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
          <span class="firstname"></span>
          <span class="initials"></span>
          <span class="lastname"></span>
        </div>
      </div>')

    person =
      firstname:  'Jasmine'
      middlename: 'Elisabeth'
      lastname:   'Taylor'

    directives =
      initials: () ->
        " #{this.middlename.substr(0,1)}. "

    expected = jQuery(
      '<div>
        <div class="person">
          <span class="firstname">Jasmine</span>
          <span class="initials"> E. </span>
          <span class="lastname">Taylor</span>
        </div>
      </div>')

    doc.find('.person').render(person, directives)
    expect(doc.html()).htmlToBeEqual(expected.html())

  it "should handle nested directives", ->
    doc = jQuery(
     '<div>
        <div class="person">
          <span class="firstname"></span>
          <span class="initials"></span>
          <span class="lastname"></span>
          <div class="friends">
            <div class="friend">
              <span class="short_name"></span>
              <span class="email"></span>
            </div>
          </div>
        </div>
      </div>')

    person =
      firstname:  'Jasmine'
      middlename: 'Elisabeth'
      lastname:   'Taylor'
      friends:    [
        firstname: 'John'
        lastname:  'Mayer'
        email:     'john.mayer@example.com'
      ,
        firstname: 'Damien'
        lastname:  'Rice'
        email:     'damien.rice@example.com'
      ]

    directives =
      initials: () ->
        " #{this.middlename.substr(0,1)}. "
      friends:
        short_name: () ->
          "#{this.firstname.substr(0,1)}. #{this.lastname}"


    expected = jQuery(
      '<div>
        <div class="person">
          <span class="firstname">Jasmine</span>
          <span class="initials"> E. </span>
          <span class="lastname">Taylor</span>
          <div class="friends">
            <div class="friend">
              <span class="short_name">J. Mayer</span>
              <span class="email">john.mayer@example.com</span>
            </div>
            <div class="friend">
              <span class="short_name">D. Rice</span>
              <span class="email">damien.rice@example.com</span>
            </div>
          </div>
        </div>
      </div>')

    doc.find('.person').render(person, directives)
    expect(doc.html()).htmlToBeEqual(expected.html())
