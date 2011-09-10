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


  it "should assing allowed attributes to the template", ->
    doc = jQuery(
     '<div>
        <div class="person">
          <img src="#" alt="" />
          <a class="name" href="#"></a>
        </div>
      </div>')

    person =
      'person@id'        : '2334'
      'person@class'     : 'person selected'
      'img@src'          : 'http://example.com/jamie.jpg'
      'img@alt'          : 'Potrait of Jamie'
      'name'             : 'Jamie Oliver'
      'name@data-undo'   : 'Jamie Olivieir'
      'a@href'           : 'http://example.com/jamie'


    expected = jQuery(
      '<div>
        <div class="person selected" id="2334">
          <img src="http://example.com/jamie.jpg" alt="Potrait of Jamie" />
          <a class="name" href="http://example.com/jamie" data-undo="Jamie Olivieir">Jamie Oliver</a>
        </div>
      </div>')

    doc.find('.person').render(person)
    expect(doc.html()).htmlToBeEqual(expected.html())

  it "should not allow event handler injections", ->
    doc = jQuery(
     '<div>
        <div class="person">
          <a class="name" href="#"></a>
        </div>
      </div>')

    person =
      'name'      : 'Jamie Oliver'
      'a@onclick' : 'alert("Calling home...")'

    expect(() -> (doc.find('.person').render(person))).toThrow()
