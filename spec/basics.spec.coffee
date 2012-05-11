require './node_helper' if module?.exports
require './spec_helper'

describe "Transparency", ->

  it "should ignore null context", ->
    template = $ '<div></div>'
    data     = hello: 'Hello'
    expected = $ '<div></div>'

    Transparency.render template.find('#not_found')[0], data
    expect(template.html()).htmlToBeEqual expected.html()

  it "should render empty container for null data", ->
    template = $ """
      <div>
        <div class="container">
          <div class="hello"></div>
          <div class="goodbye"></div>
        </div>
      </div>
      """

    data = null

    expected = $ """
      <div>
        <div class="container">
        </div>
      </div>
      """

    template.find('.container').render data
    expect(template.html()).htmlToBeEqual expected.html()

    # Assert that the template is still available
    data =
      hello: 'Hello'

    expected = $ """
      <div>
        <div class="container">
          <div class="hello">Hello</div>
          <div class="goodbye"></div>
        </div>
      </div>
      """

    template.find('.container').render data
    expect(template.html()).htmlToBeEqual expected.html()

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
    expect(template.html()).htmlToBeEqual expected.html()

  it "should match model keys to template by element id, class, name attribute and data-bind attribute", ->
    template = $ """
      <div class="container">
        <div id="my-id"></div>
        <div class="my-class"></div>
        <div data-bind="my-data"></div>
      </div>
      """

    data =
      'my-id':   'id-data'
      'my-class': 'class-data'
      'my-data' : 'data-bind'

    expected = $ """
      <div class="container">
        <div id="my-id">id-data</div>
        <div class="my-class">class-data</div>
        <div data-bind="my-data">data-bind</div>
      </div>
      """

    res = template.render data
    expect(template.html()).htmlToBeEqual expected.html()

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
    expect(template.html()).htmlToBeEqual expected.html()

  it "should work with numeric values", ->
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
    expect(template.html()).htmlToBeEqual expected.html()

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
    expect(template.html()).htmlToBeEqual expected.html()

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
    expect(template.html()).htmlToBeEqual expected.html()
