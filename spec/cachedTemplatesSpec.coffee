describe "Transparency", ->

  it "cache templates", ->
    doc = $ """
      <div>
        <div class="container">
          <div>
            <span class="hello"></span>
            <span class="world"></span>
          </div>
        </div>
      </div>
      """

    data = [
      hello: "Hello"
      world: "World!"
    ,
      hello: "Goodbye"
      world: "Canada!"
    ]

    expected = $ """
      <div>
        <div class="container">
          <div>
            <span class="hello">Hello</span>
            <span class="world">World!</span>
          </div>
          <div>
            <span class="hello">Goodbye</span>
            <span class="world">Canada!</span>
          </div>
        </div>
      </div>
      """

    doc.find('.container').render(data)
    doc.find('.container').render(data)
    expect(doc).toBeEqual(expected)
