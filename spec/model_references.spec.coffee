describe "Each element in a template instance", ->

  it "should have reference to the rendered model", ->
    template = $ """
      <div id="template">
          <li><a class="name"><span>Moar text</span></a></div>
      </div>
      """

    data = [
      name: 'Foo'
    ,
      name: 'Bar'
    ]

    directives =
      name: text: (params) ->
        expect(data[params.index]).toEqual(params.element.transparency.model)
        @name

    template.render data, directives

    for li, i in template.find('li')
      for element in $(li).add('*', li)
        expect(data[i]).toEqual(element.transparency.model)
