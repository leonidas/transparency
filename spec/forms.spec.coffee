if module?.exports
  require './spec_helper'
  Transparency = require '../src/transparency'

describe "Transparency", ->

  it "should render values to form inputs and textarea elements", ->
    template = $ """
      <div>
        <input name="name" type="text" />
        <input name="job" type="text" />
        <textarea name="resume"></textarea>
      </div>
      """

    data =
      name: 'John'
      job: 'Milkman'
      resume: "Jack of all trades"

    expected = $ """
      <div>
        <input name="name" type="text" value="John"/>
        <input name="job" type="text" value="Milkman"/>
        <textarea name="resume">Jack of all trades</textarea>
      </div>
      """

    template.render data
    expect(template.html()).htmlToBeEqual expected.html()

  it "should render values to option elements", ->
    template = $ """
      <form>
        <select id="states">
          <option class="state"></option>
        </select>
      </form>
      """

    data =
      states: [
        id: 1
        state: 'Alabama'
      ,
        id: 2
        state: 'Alaska'
      ,
        id: 3
        state: 'Arizona'
      ]

    directives =
      states:
        state: () -> value: @id

    expected = $ """
      <form>
        <select id="states">
          <option class="state" value="1">Alabama</option>
          <option class="state" value="2">Alaska</option>
          <option class="state" value="3">Arizona</option>
        </select>
      </form>
      """

    template.render data, directives
    expect(template.html()).htmlToBeEqual expected.html()

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
    expect(template.html()).htmlToBeEqual expected.html()
