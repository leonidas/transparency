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

  it "should handle nested lists", ->
    doc = jQuery(
     '<div>
       <div class="container">
          <h1 class="title"></h1>
          <p class="post"></p>
          <div class="comments">
            <div class="comment">
              <span class="name"></span>
              <span class="text"></span>
            </div>
          </div>
        </div>
      </div>')

    data =
      title:    'Hello World'
      post:     'Hi there it is me'
      comments: [ { 
          name:    'John'
          text: 'That rules' }, { 
          name:    'Arnold'
          text: 'Great post!'}
      ]

    expected = jQuery(
     '<div>
        <div class="container">
          <h1 class="title">Hello World</h1>
          <p class="post">Hi there it is me</p>
          <div class="comments">
            <div class="comment">
              <span class="name">John</span>
              <span class="text">That rules</span>
            </div>
            <div class="comment">
              <span class="name">Arnold</span>
              <span class="text">Great post!</span>
            </div>
          </div>
        </div>
      </div>')

    doc.find('.container').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())

  it "should handle nested lists with overlapping attributes", ->
    doc = jQuery(
     '<div>
       <div class="container">
          <p class="tweet"></p>
          <div class="responses">
            <p class="tweet"></p>
          </div>
        </div>
      </div>')

    data =
      tweet: 'Jasmine is great!'
      responses: [
        tweet: 'It truly is!'
      ,
        tweet: 'I prefer JsUnit'
      ]

    expected = jQuery(
     '<div>
       <div class="container">
          <p class="tweet">Jasmine is great!</p>
          <div class="responses">
            <p class="tweet">It truly is!</p>
            <p class="tweet">I prefer JsUnit</p>
          </div>
        </div>
      </div>')

    doc.find('.container').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())

  it "should handle nested objects", ->
    doc = jQuery(
     '<div>
       <div class="container">
          <div class="firstname"></div>
          <div class="lastname"></div>
          <div class="address">
            <div class="street"></div>
            <div class="zip"><span class="city"></span></div>
          </div>
        </div>
      </div>')

    data =
      firstname: 'John'
      lastname:  'Wayne'
      address:
        street: '4th Street'
        city:   'San Francisco'
        zip:    '94199'

    expected = jQuery(
     '<div>
       <div class="container">
          <div class="firstname">John</div>
          <div class="lastname">Wayne</div>
          <div class="address">
            <div class="street">4th Street</div>
            <div class="zip">94199<span class="city">San Francisco</span></div>
          </div>
        </div>
      </div>')

    doc.find('.container').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())