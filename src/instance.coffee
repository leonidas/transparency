_       = require '../lib/lodash.js'
{chainable} = helpers = require './helpers'

# Template **Instance** is created for each model we are about to render.
# `instance` object keeps track of template DOM nodes and elements.
# It memoizes the matching elements to `queryCache` in order to speed up the rendering.
module.exports = class Instance

  constructor: (template, @Transparency) ->
    @queryCache = {}
    @childNodes = _.toArray template.childNodes
    @elements   = helpers.getElements   template

  remove: chainable ->
    for node in @childNodes
      node.parentNode.removeChild node

  appendTo: chainable (parent) ->
    for node in @childNodes
      parent.appendChild node

  prepare: chainable (model) ->
    for element in @elements
      element.reset()

      # A bit of offtopic, but let's think about writing event handlers.
      # It would be convenient to have an access to the associated `model`
      # when the user clicks a todo element without setting `data-id` attributes or other
      # identifiers manually. So be it.
      #
      #     $('#todos').on('click', '.todo', function(e) {
      #       console.log(e.target.transparency.model);
      #     });
      #
      helpers.data(element.el).model = model

  # Rendering values takes care of the most common use cases like
  # rendering text content, form values and DOM elements (.e.g., Backbone Views).
  # Rendering as a text content is a safe default, as it is HTML escaped
  # by the browsers.
  renderValues: chainable (model, children) ->
    if _.isElement(model) and element = @elements[0]
      element.empty().el.appendChild model

    else if typeof model == 'object'
      for own key, value of model when value?

        if _.isString(value) or _.isNumber(value) or _.isBoolean(value) or _.isDate(value)
          for element in @matchingElements key

            # Element type also affects on rendering. Given a model
            #
            #     {todo: 'Do some OSS', type: 2}
            #
            # `div` element should have `textContent` set,
            # `input` element should have `value` attribute set and
            # with `select` element, the matching `option` element should set to `selected="selected"`.
            #
            #       <div id="template">
            #         <div class="todo">Do some OSS</todo>
            #          <input name="todo" value="Do some OSS" />
            #          <select name="type">
            #            <option value="1">Work</option>
            #            <option value="2" selected="selected">Hobby</option>
            #          </select>
            #       </div>
            #
            element.render value

        # Rendering nested models breadth-first is more robust, as there might be colliding keys,
        # i.e., given a model
        #
        #     {
        #       name: "Jack",
        #       friends: [
        #         {name: "Matt"},
        #         {name: "Carol"}
        #       ]
        #     }
        #
        # and a template
        #
        #     <div id="person">
        #       <div class="name"></div>
        #       <div class="friends">
        #         <div class="name"></div>
        #       </div>
        #     </div>
        #
        # the depth-first rendering might give us wrong results, if the children are rendered
        # before the `name` field on the parent model (child template values are overwritten by the parent).
        #
        #     <div id="person">
        #       <div class="name">Jack</div>
        #       <div class="friends">
        #         <div class="name">Jack</div>
        #         <div class="name">Jack</div>
        #       </div>
        #     </div>
        #
        # Save the key of the child model and take care of it once
        # we're done with the parent model.
        else if typeof value == 'object'
          children.push key

  # With `directives`, user can give explicit rules for rendering and set
  # attributes, which would be potentially unsafe by default (e.g., unescaped HTML content or `src` attribute).
  # Given a template
  #
  #     <div class="template">
  #       <div class="escaped"></div>
  #       <div class="unescaped"></div>
  #       <img class="trusted" src="#" />
  #     </div>
  #
  # and a model and directives
  #
  #     model = {
  #       content: "<script>alert('Injected')</script>"
  #       url: "http://trusted.com/funny.gif"
  #     };
  #
  #     directives = {
  #       escaped: { text: { function() { return this.content } } },
  #       unescaped: { html: { function() { return this.content } } },
  #       trusted: { url: { function() { return this.url } } }
  #     }
  #
  #     $('#template').render(model, directives);
  #
  # should give the result
  #
  #     <div class="template">
  #       <div class="escaped">&lt;script&gt;alert('Injected')&lt;/script&gt;</div>
  #       <div class="unescaped"><script>alert('Injected')</script></div>
  #       <img class="trusted" src="http://trusted.com/funny.gif" />
  #     </div>
  #
  # Directives are executed after the default rendering, so that they can be used for overriding default rendering.
  renderDirectives: chainable (model, index, directives) ->
    for own key, attributes of directives when typeof attributes == 'object'
      model = {value: model} unless typeof model == 'object'

      for element in @matchingElements key
        element.renderDirectives model, index, attributes

  renderChildren: chainable (model, children, directives, options) ->
    for key in children
      for element in @matchingElements key
        @Transparency.render element.el, model[key], directives[key], options

  matchingElements: (key) ->
    elements = @queryCache[key] ||= (el for el in @elements when @Transparency.matcher el, key)
    helpers.log "Matching elements for '#{key}':", elements
    elements

