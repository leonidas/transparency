describe "Transparency", ->

  it "should render plain values with global directives", ->


    globalDirective =
        'global-test':
            title : (params) ->
                return this.name
        'global-backgroundColor':
            style : (params) ->
                return 'background-color: ' + this.color


    template = $ """
      <div>
        <div data-bind="loop">
            <span data-bind="name" class="global-test"></span>
            <div data-bind="cars">
                <span data-bind="color" class="global-backgroundColor"></span>
            </div>
            <hr>
        </div>
      </div>
      """

    data =
      loop: [
          {
              "name" : "John"
              "cars" : [
                  {"color" : "red"}
                  {"color" : "blue"}
              ]
          }
          {
              "name" : "Michael"
              "cars" : [
                  {"color" : "yellow"}
                  {"color" : "green"}
              ]
          }
      ]

    expected = $ """
      <div>
        <div data-bind="loop">
            <span data-bind="name" class="global-test" title="John">John</span>
            <div data-bind="cars">
                <span data-bind="color" class="global-backgroundColor" style="background-color: red">red</span>
                <span data-bind="color" class="global-backgroundColor" style="background-color: blue">blue</span>
            </div>
            <hr>
            <span data-bind="name" class="global-test" title="Michael">Michael</span>
            <div data-bind="cars">
                <span data-bind="color" class="global-backgroundColor" style="background-color: yellow">yellow</span>
                <span data-bind="color" class="global-backgroundColor" style="background-color: green">green</span>
            </div>
            <hr>
        </div>
      </div>
      """

    Transparency.setGlobalDirectives globalDirective

    template.render data
    expect(template).toBeEqual expected
