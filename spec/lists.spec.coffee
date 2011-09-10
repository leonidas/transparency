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

  it "should handle list of objects", ->
    doc = jQuery(
     '<div>
        <div class="comments">
          <div class="comment">
            <span class="name"></span>
            <span class="text"></span>
          </div>
        </div>
      </div>')

    data = [ 
      { name: 'John',   text: 'That rules'  }, 
      { name: 'Arnold', text: 'Great post!' }
    ]

    expected = jQuery(
     '<div>
        <div class="comments">
          <div class="comment">
            <span class="name">John</span>
            <span class="text">That rules</span>
          </div><div class="comment">
            <span class="name">Arnold</span>
            <span class="text">Great post!</span>
          </div>
        </div>
      </div>')

    doc.find('.comments').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())
