if module?.exports
  require './spec_helper'
  Transparency = require '../src/transparency'

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
        <textarea name="resume">Jack of all trades</textarea>
      </div>
      """

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
        <option class="state" value="1" selected="selected">Alabama</option>
        <option class="state" value="2">Alaska</option>
        <option class="state" value="3">Arizona</option>
      </select>
      """

    template.render data, directives
    template.children().first().attr 'selected', 'selected'
    expect(template).toBeEqual expected

  it "should set a matching option in case the target element is 'select'", ->
    template = $ """
      <select name="state">
        <option class="state" value="1">Alabama</option>
        <option class="state" value="2">Alaska</option>
        <option class="state" value="3">Arizona</option>
      </select>
      """

    data = [
      name: 2
      state: 'Alaska'
    ]

    directives = state: value: ->  name

    expected = $ """
      <select name="state">
        <option class="state" value="1">Alabama</option>
        <option class="state" value="2" selected="selected">Alaska</option>
        <option class="state" value="3">Arizona</option>
      </select>
      """

    template.render data, directives
    template.children().first().attr 'selected', 'selected'
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
          <option class="comment" selected="selected">John</option>
          <option class="comment">Arnold</option>
        </select>
      </div>
      """

    template.render data
    template.find(".comment").first().attr 'selected', 'selected'
    expect(template).toBeEqual expected
