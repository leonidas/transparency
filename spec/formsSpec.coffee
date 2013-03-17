describe "Transparency", ->

  it "should render values to form inputs and textarea elements", ->
    template = $ """
      <div>
        <input name="name"/>
        <input name="job"/>
        <textarea name="resume"></textarea>
      </div>
      """

    data =
      name: 'John'
      job: 'Milkman'
      resume: "Jack of all trades"

    expected = $ """
      <div>
        <input name="name" value="John"/>
        <input name="job" value="Milkman"/>
        <textarea name="resume" value="Jack of all trades"></textarea>
      </div>
      """

    # Needed for IE
    expected.find('textarea').val 'Jack of all trades'
    template.render data
    expect(template).toBeEqual expected

  it "should render values to option elements", ->
    template = $ """
      <select id="states">
        <option class="state"></option>
      </select>
      """

    data = [
      id: 1
      state: 'Alabama'
    ,
      id: 2
      state: 'Alaska'
    ,
      id: 3
      state: 'Arizona'
    ]

    directives = state: value: -> @id

    expected = $ """
      <select id="states">
        <option class="state" value="1">Alabama</option>
        <option class="state" value="2">Alaska</option>
        <option class="state" value="3">Arizona</option>
      </select>
      """

    template.render data, directives
    template.children().first().prop 'selected', true
    expect(template).toBeEqual expected

  it "should render list of options and set the selected", ->
    template = $ """
      <select class="foo" multiple>
          <option class="bar"></option>
      </select>
      """

    data = [
      id:1, name:"First"
    ,
      id:2, name:"Second"
    ,
      id:3, name:"Third"
    ]

    directives =
        bar:
          value:    -> @id
          text:     -> @name
          selected: -> true

    expected = $ """
      <select class="foo" multiple>
          <option class="bar" value="1">First</option>
          <option class="bar" value="2">Second</option>
          <option class="bar" value="3">Third</option>
      </select>
      """

    template.render data, directives
    expect(template).toBeEqual expected

  it "should set the matching option to 'selected' in case the target element is 'select'", ->
      template = $ """
        <div>
          <select class="state">
            <option value="1">Alabama</option>
            <option value="2">Alaska</option>
            <option value="3">Arizona</option>
          </select>
        </div>
        """

      data = state: 2

      expected = $ """
        <div>
          <select class="state">
            <option value="1">Alabama</option>
            <option value="2" selected="selected">Alaska</option>
            <option value="3">Arizona</option>
          </select>
        </div>
        """

      template.render data
      expect(template).toBeEqual expected

  it "should handle nested options elements", ->
    template = $ """
      <div class="container">
        <h1 class="title"></h1>
        <p class="post"></p>
        <select class="comments">
          <option class="comment">test</option>
        </select>
      </div>
      """

    data =
      title: 'Hello World'
      post:  'Hi there it is me'
      comments: [
        comment: 'John'
      , comment: 'Arnold'
      ]

    expected = $ """
      <div class="container">
        <h1 class="title">Hello World</h1>
        <p class="post">Hi there it is me</p>
        <select class="comments">
          <option class="comment">John</option>
          <option class="comment">Arnold</option>
        </select>
      </div>
      """

    template.render data
    expect(template).toBeEqual expected

  it "should render checkbox and radiobutton checked attributes", ->
    template = $ """
      <div class="template">
        <input type="checkbox" name="foo" value="Foo" />
        <input type="checkbox" name="foz" value="Foz" />
        <input type="radio" name="bar" value="Bar" />
        <input type="radio" name="baz" value="Baz" />
      </div>
      """

    data =
      foo: true
      foz: false
      bar: true
      baz: false

    expected = $ """
      <div class="template">
        <input type="checkbox" name="foo" value="Foo" checked="checked" />
        <input type="checkbox" name="foz" value="Foz" />
        <input type="radio" name="bar" value="Bar" checked="checked" />
        <input type="radio" name="baz" value="Baz" />
      </div>
      """

    template.render data
    expect(template).toBeEqual expected

