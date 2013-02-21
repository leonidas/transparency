describe "Transparency", ->

  it "should ignore null context", ->
    template = $ '<div></div>'
    data     = hello: 'Hello'
    expected = $ '<div></div>'

    window.Transparency.render template.find('#not_found')[0], data
    expect(template).toBeEqual expected

  it "should render empty container for null data", ->
    template = jQuery """
      <div class="container">
        <div class="hello"></div>
        <div class="goodbye"></div>
      </div>
      """

    data = null

    expected = $ """
      <div class="container">
      </div>
      """

    template.render data
    expect(template).toBeEqual expected

    # Assert that the template is still available
    data =
      hello: 'Hello'

    expected = $ """
      <div class="container">
        <div class="hello">Hello</div>
        <div class="goodbye"></div>
      </div>
      """

    template.render data
    expect(template).toBeEqual expected

  it "should ignore null values", ->
    template = $ """
      <div class="container">
        <div class="hello"></div>
        <div class="goodbye"></div>
      </div>
      """

    data =
      hello:   'Hello'
      goodbye: null

    expected = $ """
      <div class="container">
        <div class="hello">Hello</div>
        <div class="goodbye"></div>
      </div>
      """

    template.render data
    expect(template).toBeEqual expected

  it "should match model keys to template by element id, class, name attribute and data-bind attribute", ->
    template = $ """
      <div class="container">
        <div id="my-id"></div>
        <div class="my-class"></div>
        <input name="my-name" />
        <div data-bind="my-data"></div>
      </div>
      """

    data =
      'my-id':    'id-data'
      'my-class': 'class-data'
      'my-name':  'name-data'
      'my-data' : 'data-bind'

    expected = $ """
      <div class="container">
        <div id="my-id">id-data</div>
        <div class="my-class">class-data</div>
        <input name="my-name" value="name-data" />
        <div data-bind="my-data">data-bind</div>
      </div>
      """

    template.render data
    expect(template).toBeEqual expected

  it "should handle nested templates", ->
    template = $ """
      <div class="container">
        <div class="greeting">
          <span class="name"></span>
          <div class="greeting"></div>
        </div>
      </div>
      """

    data =
      greeting: 'Hello'
      name:     'World'

    expected = $ """
      <div class="container">
        <div class="greeting">Hello<span class="name">World</span>
          <div class="greeting">Hello</div>
        </div>
      </div>
      """

    template.render data
    expect(template).toBeEqual expected

  it "should handle numeric values", ->
    template = $ """
      <div class="container">
        <div class="hello"></div>
        <div class="goodbye"></div>
      </div>
      """

    data =
      hello:   'Hello'
      goodbye: 5

    expected = $ """
      <div class="container">
        <div class="hello">Hello</div>
        <div class="goodbye">5</div>
      </div>
      """

    template.render data
    expect(template).toBeEqual expected

  it "should handle DOM elements as models", ->
    template = $ """
      <div id="template">
        <h1 class="title"></h1>
        <div class="widgets">
          <div class="widget"></div>
        </div>
      </div>
      """

     # Few widget elements. In reality these would be created other by Backbone views.
    widget1 = $("<div>First</div>")[0]
    widget2 = $("<div>Second</div>")[0]

    data =
      title: "Some widgets"
      widgets: [widget1,  widget2]

    expected = $ """
      <div id="template">
        <h1 class="title">Some widgets</h1>
        <div class="widgets">
          <div class="widget">
            <div>First</div>
          </div>
          <div class="widget">
            <div>Second</div>
          </div>
        </div>
      </div>
      """

    template.render data
    expect(template).toBeEqual expected

  it "should convert date objects to strings", ->
    template = $ """
      <div class="container">
        <div class="best_before"></div>
      </div>
      """

    data =
      best_before: new Date 0

    expected = $ """
      <div class="container">
        <div class="best_before">#{(new Date 0).toString()}</div>
      </div>
      """

    template.render data
    expect(template).toBeEqual expected

  it "should ignore functions in models", ->
    template = $ """
      <div class="container">
        <div class="hello"></div>
        <div class="goodbye"></div>
        <div class="skipped"></div>
      </div>
      """

    data =
      hello:   'Hello'
      goodbye: 5
      skipped: () -> "hello"

    expected = $ """
      <div class="container">
        <div class="hello">Hello</div>
        <div class="goodbye">5</div>
        <div class="skipped"></div>
      </div>
      """

    template.render data
    expect(template).toBeEqual expected

  it "should preserve text between template elements", ->
    template = $ """
      <li class="foo">
      <span data-bind="begin"></span> - <span data-bind="end"></span>
      </li>
      """

    data =
      begin: 'asdf'
      end:   'fdsa'

    expected = $ """
      <li class="foo">
      <span data-bind="begin">asdf</span> - <span data-bind="end">fdsa</span>
      </li>
      """

    template.render data
    expect(template).toBeEqual expected

  it "should render empty string, zero and other falsy values", ->
    template = $ """
      <div id="root">
          <span id="number">234</span>
          <span id="bool">foo</span>
          <span id="dec">1.234</span>
          <span id="str">abc</span>
      </div>​
      """

    data =
      number: 0
      bool: false
      dec: 0.0
      str: ""

    expected = $ """
     <div id="root">
        <span id="number">0</span>
        <span id="bool">false</span>
        <span id="dec">0</span>
        <span id="str"></span>
      </div>​
      """

    template.render data
    expect(template).toBeEqual expected

  it "should not render text content to img tags and other void elements", ->
      # See https://github.com/leonidas/transparency/issues/82

      template = $ """
        <div id="gallery">
          <b data-bind="name"></b>
          <img data-bind="image" src="" alt="" />
        </div>
        """

      data = [
        name: 'gal1'
        image: 'http://example.com/image_name_1'
      ,
        name: 'gal2'
        image: 'http://example.com/image_name_2'
      ]

      directives =
        name:  text: -> @name
        image: src:  -> @image

      expected = $ """
        <div id="gallery">
          <b data-bind="name">gal1</b>
          <img data-bind="image" src="http://example.com/image_name_1" alt="" />
          <b data-bind="name">gal2</b>
          <img data-bind="image" src="http://example.com/image_name_2" alt="" />
        </div>
        """

      template.render data, directives
      expect(template).toBeEqual expected
