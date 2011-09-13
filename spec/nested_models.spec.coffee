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
      responses: [
        tweet: 'It truly is!'
      ,
        tweet: 'I prefer JsUnit'
      ]
      tweet: 'Jasmine is great!'

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

  it "should handle tables with dynamic headers", ->
    doc = jQuery(
     '<div>
       <table class="test_reports">
          <thead>
            <tr class="profiles">
              <th class="name"></th>
            </tr>
          </thead>
          <tbody>
            <tr class="profiles">
              <td class="testsets">
                <div class="testset">
                  <a href="#" class="name"></a>
                  <ul class="products">
                    <li>
                      <a href="#" class="name"></a>
                    </li>
                  </ul>
                </div>
          </tbody>
        </table>
      </div>')

    data =
      profiles: [
        name: 'Core'
        testsets: [ 
          name: "Core Sanity"
          products: [
            name: "Core Sanity N900"
          ,
            name: "Core Sanity Lenovo"
          ]
        ,
          name: "Core Acceptance"
          products: [
            name: "Core Acceptance Netbook"
          ,
            name: "Core Acceptance Pinetrail"
          ]
        ]
      , 
        name: 'Handset'
        testsets: [
          name: "Handset Sanity"
          products: [
            name: "Handset Sanity N900"
          ,
            name: "Handset Sanity Lenovo"
          ]
        ,
          name: 'Handset Acceptance'
          products: [
            name: "Handset Acceptance Netbook"
          ,
            name: "Handset Acceptance Pinetrail"
          ]
        ]
      ]

    expected = jQuery(
     '<div>
       <table class="test_reports">
          <thead>
            <tr class="profiles">
              <th class="name">Core</th>
              <th class="name">Handset</th>
            </tr>
          </thead>
          <tbody>
            <tr class="profiles">
              <td class="testsets">
                <div class="testset">
                  <a href="#" class="name">Core Sanity</a>
                  <ul class="products">
                    <li>
                      <a href="#" class="name">Core Sanity N900</a>
                    </li>
                    <li>
                      <a href="#" class="name">Core Sanity Lenovo</a>
                    </li>
                  </ul>
                </div>
                <div class="testset">
                  <a href="#" class="name">Core Acceptance</a>
                  <ul class="products">
                    <li>
                      <a href="#" class="name">Core Acceptance Netbook</a>
                    </li>
                    <li>
                      <a href="#" class="name">Core Acceptance Pinetrail</a>
                    </li>
                  </ul>
                </div>
              </td>

              <td class="testsets">
                <div class="testset"
                  <a href="#" class="name">Handset Sanity</a>
                  <ul class="products">
                    <li>
                      <a href="#" class="name">Handset Sanity N900</a>
                    </li>
                    <li>
                      <a href="#" class="name">Handset Sanity Lenovo</a>
                    </li>
                  </ul>
                </div>
                <div class="testset"
                  <a href="#" class="name">Handset Acceptance</a>
                  <ul class="products">
                    <li>
                      <a href="#" class="name">Handset Acceptance Netbook</a>
                    </li>
                    <li>
                      <a href="#" class="name">Handset Acceptance Pinetrail</a>
                    </li>
                  </ul>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>')

    doc.find('.test_reports').render(data)
    expect(doc.html()).htmlToBeEqual(expected.html())