# fake browser window
global.jsdom  = require 'jsdom'
global.window = jsdom.jsdom().createWindow()
global.jQuery = require "jquery"

require "../jquery.transparency.coffee"

describe "Transparency", ->

  beforeEach ->
    this.addMatchers
      htmlToBeEqual: (expected) ->
        this.actual = this.actual.replace(/\s\s+/g, '')
        this.actual == expected.replace(/\s\s+/g, '')


  it "should assing data values to template", ->
    doc = jQuery(
     '<div>
        <div class="container">
          <div class="greeting"></div>
          <div class="name"></div>
        </div>
      </div>')

    data =
      greeting: 'Hello '
      name:     'World!'

    expected = jQuery(
      '<div>
        <div class="container">
          <div class="greeting">Hello </div>
          <div class="name">World!</div>
        </div>
      </div>')

    doc.find('.container').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())

  it "should handle nested templates", ->
    doc = jQuery(
     '<div>
        <div class="container">
          <div class="greeting">
            <span class="name"></span>
          </div>
        </div>
      </div>')

    data =
      greeting: 'Hello '
      name:     'World!'

    expected = jQuery(
      '<div>
        <div class="container">
          <div class="greeting">Hello 
            <span class="name">World!</span>
          </div>
        </div>
      </div>')

    doc.find('.container').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())

  it "should handle attribute assignment", ->
    doc = jQuery(
     '<div>
        <div class="container">
          <a class="greeting" href="#"></a>
        </div>
      </div>')

    data =
      "greeting":      "Hello World"
      "greeting@href": "http://world"

    expected = jQuery(
      '<div>
        <div class="container">
          <a class="greeting" href="http://world">Hello World</a>
        </div>
      </div>')

    doc.find('.container').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())

  it "should handle list of objects", ->
    doc = jQuery(
     '<div>
        <div class="container">
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
        <div class="container">
          <div class="comment">
            <span class="name">John</span>
            <span class="text">That rules</span>
          </div><div class="comment">
            <span class="name">Arnold</span>
            <span class="text">Great post!</span>
          </div>
        </div>
      </div>')

    doc.find('.comment').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())

  it "should handle nested objects", ->
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
