describe "Transparency", ->

  it "should render list of objects", ->
    template = $ """
      <div class="comments">
        <div class="comment">
          <span class="name"></span><span class="text"></span>
        </div>
      </div>
      """

    data = [
      name: 'John'
      text: 'That rules'
    ,
      name: 'Arnold'
      text: 'Great post!'
    ]

    expected = $ """
      <div class="comments">
        <div class="comment">
          <span class="name">John</span><span class="text">That rules</span>
        </div><div class="comment">
          <span class="name">Arnold</span><span class="text">Great post!</span>
        </div>
      </div>
      """

    template.render data
    expect(template).toBeEqual expected
    expect(template.find('.comment')[0].transparency.model).toEqual(data[0])
    expectModelObjects template.find('.comment'), data

  it "should render empty lists", ->
    template = $ """
      <div class="comments">
        <div class="comment">
          <span class="name"></span>
          <span class="text"></span>
        </div>
      </div>
      """

    data = []

    expected = $ """
      <div class="comments">
      </div>
      """

    template.render data
    expect(template).toBeEqual expected

  it "should render lists with duplicate content", ->
    template = $ """
      <div id="items">
        <div class="name"></div>
      </div>
      """

    data = [
      name: "Same"
    , name: "Same"
    ]

    expected = $ """
      <div id="items">
        <div class="name">Same</div>
        <div class="name">Same</div>
      </div>
      """

    template.render data
    expect(template).toBeEqual expected

  it "should render plain values with 'this' directives", ->
    template = $ """
      <div class="comments">
        <label>Comment:</label>
        <span class="comment"></span>
      </div>
      """

    data       = ["That rules", "Great post!", 5]
    directives = comment: text: -> this.value

    expected = $ """
      <div class="comments">
        <label>Comment:</label>
        <span class="comment">That rules</span>
        <label>Comment:</label>
        <span class="comment">Great post!</span>
        <label>Comment:</label>
        <span class="comment">5</span>
      </div>
      """

    template.render data, directives
    expect(template).toBeEqual expected
    #expectModelObjects template.find('.listElement'), data

  it "should not fail when there's no child node in the simple list template", ->
    template = $ """
      <div class="comments">
      </div>
      """

    data = ["That rules", "Great post!"]

    expected = $ """
      <div class="comments">
      </div>
      """

    template.find('.comments').render data
    expect(template).toBeEqual(expected)

  it "should match table rows to the number of model objects", ->
    template = $ """
      <table>
        <tbody class="users">
          <tr>
            <td class="username">foobar</td>
          </tr>
        </tbody>
      </table>
      """

    template.find(".users").render [{username:'user1'}, {username:'user2'}]
    expect(template).toBeEqual $ """
      <table>
        <tbody class="users">
          <tr>
            <td class="username">user1</td>
          </tr>
          <tr>
            <td class="username">user2</td>
          </tr>
        </tbody>
      </table>
      """

    template.find(".users").render [username:'user1']
    expect(template).toBeEqual $ """
      <table>
        <tbody class="users">
          <tr>
            <td class="username">user1</td>
          </tr>
        </tbody>
      </table>
      """

    template.find(".users").render [{username:'user1'}, {username:'user3'}]
    expect(template).toBeEqual $ """
      <table>
        <tbody class="users">
          <tr>
            <td class="username">user1</td>
          </tr>
          <tr>
            <td class="username">user3</td>
          </tr>
        </tbody>
      </table>
      """

    template.find(".users").render [{username:'user4'}, {username:'user3'}]
    expect(template).toBeEqual $ """
      <table>
        <tbody class="users">
          <tr>
            <td class="username">user4</td>
          </tr>
          <tr>
            <td class="username">user3</td>
          </tr>
        </tbody>
      </table>
      """

expectModelObjects = (elements, data) ->
  for object, i in data
    expect(elements[i].transparency.model).toEqual(object)
