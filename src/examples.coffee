window.examples =
  "assigning-values":
    coffee:
      """
      hello =
        hello: "Hello!"
        hi:    "<i>Hi there!</i>"
        span:  "Goodbye!"

      $('.container').render hello
      """
    jade:
      """
      .container
        #hello
        .hi
        span
      """

  "iterating-over-a-list":
    coffee:
      """
      activities = [
        date:     '2011-08-23'
        activity: 'Jogging'
        comment:  'Early morning run'
        name:     'Harry Potter'
      ,
        date:     '2011-09-04'
        activity: 'Gym'
        comment:  'Chest workout'
        name:     'Batman'
      ]

      $('.activities').render activities
      """
    jade:
      """
      table
        thead
          tr
            th Date
            th Activity
            th Comment
            th Name
        tbody.activities
          tr
            td.date
            td.activity
            td.comment
            td.name
      """

  "nested-lists":
    coffee:
      """
      post =
        title:    'Hello World',
        post:     'Hi there it is me',
        comments: [
          name: 'John',
          text: 'That rules'
        ,
          name: 'Arnold',
          text: 'Great post!'
        ]

      $('.container').render post
      """
    jade:
      """
      .container
        h1.title
        p.post
        .comments
          .comment
            span.name
            span.text
      """

  "nested-objects":
    coffee:
      """
      person =
        firstname: 'John'
        lastname: 'Wayne'
        address:
          street: '4th Street'
          city: 'San Francisco'
          zip: 94199

      $(".person").render person
      """
    jade:
      """
      .person
        .firstname
        .lastname
        .address
          .street
          .zip
            span.city
      """

  "directives":
    coffee:
      """
      person =
        firstname: 'Jasmine'
        lastname:  'Taylor'
        email:     'jasmine.tailor@example.com'

      directives =
        name:  -> "\#{@firstname} \#{@lastname}"
        email: -> href: "mailto:\#{@email}"

      $('.person').render person, directives
      """
    jade:
      """
      .person
        .name
        a.email
      """

  "nested-directives":
    coffee:
      """
      person =
        firstname: 'Jasmine'
        lastname: 'Taylor'
        email: 'jasmine.taylor@example.com'
        friends: [
          firstname: 'John'
          lastname: 'Mayer'
          email: 'john.mayer@example.com'
        ,
          firstname: 'Damien'
          lastname: 'Rice'
          email: 'damien.rice@example.com'
        ]

      nameDecorator = ->
        "\#{@firstname} \#{@lastname}"

      directives =
        name: nameDecorator
        friends:
          name: nameDecorator

      $('.person').render person, directives
      """
    jade:
      """
      .person
        .name
        .email
        .friends
          .friend
            .name
            .email
      """