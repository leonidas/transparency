require './spec_helper'
require '../jquery.transparency'

describe "Transparency", ->

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
      title: 'Hello World'
      post:  'Hi there it is me'
      comments: [
        name: 'John'
        text: 'That rules'
      ,
        name: 'Arnold'
        text: 'Great post!'
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
              <th>
                <a class="name" href="#"></a>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr class="profiles">
              <td class="testsets">
                <div class="testset">
                  <a class="name" href="#"></a>
                  <ul class="products">
                    <li>
                      <a class="name" href="#"></a>
                    </li>
                  </ul>
                </div>
          </tbody>
        </table>
      </div>')

    data =
      release: "1.2"
      profiles: [
        name: 'Core'
        testsets: [
          name: "Sanity"
          products: [
            name: "N900"
          ,
            name: "Lenovo"
          ]
        ,
          name: "Acceptance"
          products: [
            name: "Netbook"
          ,
            name: "Pinetrail"
          ]
        ]
      ,
        name: 'Handset'
        testsets: [
          name: "Feature"
          products: [
            name: "N900"
          ,
            name: "Lenovo"
          ]
        ,
          name: 'NFT'
          products: [
            name: "Netbook"
          ,
            name: "iCDK"
          ]
        ]
      ]

    directives =
      profiles:
        'name@href': (elem) -> "/#{data.release}/#{@name}"
        testsets:
          'name@href': (elem) ->
            "/#{data.release}/#{@parent_.name}/#{@name}"
          products:
           'name@href': (elem) ->
              "/#{data.release}/#{@parent_.parent_.name}/#{@parent_.name}/#{@name}"

    expected = jQuery(
     '<div>
       <table class="test_reports">
          <thead>
            <tr class="profiles">
              <th>
                <a class="name" href="/1.2/Core">Core</a>
              </th>
              <th>
                <a class="name" href="/1.2/Handset">Handset</a>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr class="profiles">
              <td class="testsets">
                <div class="testset">
                  <a class="name" href="/1.2/Core/Sanity">Sanity</a>
                  <ul class="products">
                    <li>
                      <a class="name" href="/1.2/Core/Sanity/N900">N900</a>
                    </li>
                    <li>
                      <a class="name" href="/1.2/Core/Sanity/Lenovo">Lenovo</a>
                    </li>
                  </ul>
                </div>
                <div class="testset">
                  <a class="name" href="/1.2/Core/Acceptance">Acceptance</a>
                  <ul class="products">
                    <li>
                      <a class="name" href="/1.2/Core/Acceptance/Netbook">Netbook</a>
                    </li>
                    <li>
                      <a class="name" href="/1.2/Core/Acceptance/Pinetrail">Pinetrail</a>
                    </li>
                  </ul>
                </div>
              </td>

              <td class="testsets">
                <div class="testset"
                  <a class="name" href="/1.2/Handset/Feature">Feature</a>
                  <ul class="products">
                    <li>
                      <a class="name" href="/1.2/Handset/Feature/N900">N900</a>
                    </li>
                    <li>
                      <a class="name" href="/1.2/Handset/Feature/Lenovo">Lenovo</a>
                    </li>
                  </ul>
                </div>
                <div class="testset"
                  <a class="name" href="/1.2/Handset/NFT">NFT</a>
                  <ul class="products">
                    <li>
                      <a class="name" href="/1.2/Handset/NFT/Netbook">Netbook</a>
                    </li>
                    <li>
                      <a class="name" href="/1.2/Handset/NFT/iCDK">iCDK</a>
                    </li>
                  </ul>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>')

    doc.find('.test_reports').render(data, directives)
    expect(doc.html()).htmlToBeEqual(expected.html())
