# fake browser window
global.jsdom  = require 'jsdom'
global.window = jsdom.jsdom().createWindow()
global.jQuery = require "jquery"

require "../jquery.transparency.coffee"

describe "Transparency", ->

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
    expect(doc.html()).toEqual(expected.html())

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
    expect(doc.html()).toEqual(expected.html())

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
    expect(doc.html()).toEqual(expected.html())

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
    expect(doc.html()).toEqual(expected.html())

  # it "should handle nested objects", ->
  #   template = jQuery(
  #    '<div class="container">
  #       <h1 class="title"></h>
  #       <p class="post"></p>
  #       <div class="comments">
  #         <div>
  #           <span class="name"></span>
  #           <span class="comment"></span>
  #         </div>
  #       </div>
  #     </div>')

  #   data =
  #     title:    'Hello World'
  #     post:     'Hi there it is me'
  #     comments: [ { 
  #         name:    'John'
  #         comment: 'That rules' }, { 
  #         name:    'Arnold'
  #         comment: 'Great post!'}
  #     ]

  #   result = jQuery(
  #    '<div class="container">
  #       <h1 class="title">Hello World</h>
  #       <p class="post">Hi there it is me</p>
  #       <div class="comments">
  #         <div>
  #           <span class="name">John</span>
  #           <span class="comment">That rules</span>
  #         </div>
  #         <div>
  #           <span class="name">Arnold</span>
  #           <span class="comment">Great post!</span>
  #         </div>
  #       </div>
  #     </div>')

  #   expect(result.length).toEqual(template.render(data).length)