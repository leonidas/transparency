require './spec_helper'
require '../src/jquery.transparency'

describe "Transparency", ->

  it "should provide reference to original data", ->
    doc = jQuery(
     '<div>
        <div class="person">
          <span class="name"></span>
          <span class="email"></span>
        </div>
      </div>')

    person =
      name:  'Jasmine Taylor'
      email: 'jasmine.tailor@example.com'

    doc.find('.person').render person
    object = doc.find('.name').data('object')
    expect(object).toEqual(person)

  it "should allow updating original data", ->
    doc = jQuery(
     '<div>
        <div class="person">
          <span class="name"></span>
          <span class="email"></span>
        </div>
      </div>')

    person =
      name:  'Jasmine Taylor'
      email: 'jasmine.tailor@example.com'

    doc.find('.person').render person
    object = doc.find('.person .name').data('object')
    object.name = 'Frank Sinatra'

    expect(object.name).toEqual(person.name)