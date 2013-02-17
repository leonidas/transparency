# **Transparency** is a client-side template engine which binds JSON objects to DOM elements.
#
#     //  Template:
#     //
#     //  <ul id="todos">
#     //    <li class="todo"></li>
#     //  </ul>
#
#     template = document.querySelector('#todos');
#
#     models = [
#       {todo: "Eat"},
#       {todo: "Do some programming"},
#       {todo: "Sleep"}
#     ];
#
#     Transparency.render(template, models);
#
#     //  Result:
#     //  <ul id="todos">
#     //    <li class="todo">Eat</li>
#     //    <li class="todo">Do some programming</li>
#     //    <li class="todo">Sleep</li>
#     //   </ul>
#
# This documentation focuses on the implementation and internals.
# For the full API reference, please see the README.

# ## Public API
Transparency = @Transparency = {}

# `Transparency.render` maps JSON objects to DOM elements.
Transparency.render = (context, models = [], directives = {}, options = {}) ->
  # First, check if we are in debug mode and if so, log the arguments.
  log = if options.debug and console then consoleLogger else nullLogger
  log "Transparency.render:", context, models, directives, options

  return unless context
  models = [models] unless isArray models

  # Context element, state and functionality is wrapped to `Context` object. Get it, or create a new
  # if it doesn't exist yet.
  context = data(context).context ||= new Context(context)

  # Rendering is a lot faster when the context element is detached from the DOM, as
  # reflow calculations are not triggered. So, detach it before rendering.
  context
    .detach()
    .render(models, directives, options)
    .attach()

# ### Configuration

# In order to use Transparency as a jQuery plugin, add Transparency.jQueryPlugin to jQuery.fn object.
#
#     $.fn.render = Transparency.jQueryPlugin;
#
#     // Render with jQuery
#     $('#template').render({hello: 'World'});
Transparency.jQueryPlugin = (models, directives, options) ->
  for context in this
    Transparency.render context, models, directives, options
  this

# By default, Transparency matches model properties to elements by `id`, `class`, `name` and `data-bind` attributes.
# Override `Transparency.matcher` to change the default behavior.
#
#     // Match only by `data-bind` attribute
#     Transparency.matcher = function (element, key) {
#       element.getAttribute('data-bind') == key;
#     };
Transparency.matcher = (element, key) ->
  element.el.id                        == key ||
  key in element.classNames                   ||
  element.el.name                      == key ||
  element.el.getAttribute('data-bind') == key

# IE6-8 fails to clone nodes properly. By default, Transparency uses jQuery.clone() as a shim.
# Override `Transparency.clone` with a custom clone function, if oldIE needs to be
# supported without jQuery.
#
#     Transparency.clone = myCloneFunction;
Transparency.clone = (node) -> (jQuery || Zepto)?(node).clone()[0]

# ## Internals

# 'Chainable' method decorator.
#
#     // in console
#     > o = {}
#     > o.hello = "Hello"
#     > o.foo = chainable(function(){console.log(this.hello + " World")});
#     > o.foo().hello
#     Hello World
#     "Hello"
#
chainable = (method) -> -> method.apply(this, arguments); this

# **Context** stores the original `template` elements and is responsible for creating,
# adding and removing template `instances` to match the amount of `models`.
class Context
  constructor: (@el) ->
    @template      = cloneNode @el
    @instances     = [new Instance(@el)]
    @instanceCache = []

  detach: chainable ->
    @parent = @el.parentNode
    if @parent
      @nextSibling = @el.nextSibling
      @parent.removeChild @el

  attach: chainable ->
    if @parent
      if @nextSibling
      then @parent.insertBefore @el, @nextSibling
      else @parent.appendChild @el

  render: chainable (models, directives, options) ->

    # Cloning DOM elements is expensive, so save unused template `instances` and reuse them later.
    while models.length < @instances.length
      @instanceCache.push @instances.pop().remove()

    for model, index in models
      unless instance = @instances[index]
        instance = @instanceCache.pop() || new Instance(cloneNode(@template))
        @instances.push instance.appendTo(@el)

      instance.render(model, index, directives, options)

# Template **Instance** is created for each model we are about to render.
# `instance` object keeps track of template DOM nodes and elements.
# It memoizes the matching elements to `queryCache` in order to speed up the rendering.
class Instance
  constructor: (template) ->
    @queryCache = {}
    @childNodes = getChildNodes template
    @elements   = getElements   template

  remove: chainable ->
    for node in @childNodes
      node.parentNode.removeChild node

  appendTo: chainable (parent) ->
    for node in @childNodes
      parent.appendChild node

  render: chainable (model, index, directives, options) ->
    children = []

    @reset(model)
      .renderValues(model, children)
      .renderDirectives(model, index, directives)
      .renderChildren(model, children, directives, options)

  reset: chainable (model) ->
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
      data(element.el).model = model

  # Rendering values takes care of the most common use cases like
  # rendering text content, form values and DOM elements (.e.g., Backbone Views).
  # Rendering as a text content is a safe default, as it is HTML escaped
  # by the browsers.
  renderValues: chainable (model, children) ->
    if isDomElement(model) and element = @elements[0]
      element.empty().el.appendChild model

    else if typeof model == 'object'
      for own key, value of model when value?
        # The value can be either a nested model or a plain value, i.e., `Date`, `string`, `boolean` or `double`.
        # Start by handling the plain values and finding the matching elements.
        if isPlainValue value
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
            if element.nodeName == 'input'
              element.attr 'value', value
            else if element.nodeName == 'select'
              element.attr 'selected', value
            else element.attr 'text',  value

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
    return this unless directives
    model = if typeof model == 'object' then model else value: model

    for own key, attributes of directives when typeof attributes == 'object'
      for element in @matchingElements key
        for attribute, directive of attributes when typeof directive == 'function'

          value = directive.call model,
            element: element.el
            index:   index
            value:   element.originalAttributes[attribute]

          element.attr(attribute, value) if value?

  renderChildren: chainable (model, children, directives, options) ->
    for key in children
      for element in @matchingElements key
        Transparency.render element.el, model[key], directives[key], options

  matchingElements: (key) ->
    elements = @queryCache[key] ||= (el for el in @elements when Transparency.matcher el, key)
    log "Matching elements for '#{key}':", elements
    elements

getChildNodes = (el) ->
  childNodes = []
  child = el.firstChild
  while child
    childNodes.push child
    child = child.nextSibling
  childNodes

getElements  = (el) ->
  elements = []
  _getElements el, elements
  elements

_getElements = (template, elements) ->
  child = template.firstChild
  while child
    if child.nodeType == ELEMENT_NODE
      elements.push new Element(child)
      _getElements child, elements

    child = child.nextSibling

class Element
  constructor: (@el) ->
    @childNodes         = getChildNodes @el
    @nodeName           = @el.nodeName.toLowerCase()
    @classNames         = @el.className.split ' '
    @isVoidElement      = @nodeName in VOID_ELEMENTS
    @originalAttributes = {}

  empty: ->
    @el.removeChild child while child = @el.firstChild
    this

  reset: ->
    for attribute, value of @originalAttributes
      @attr attribute, value

  setHtml: (html) ->
    @empty()
    @el.innerHTML = html
    for child in @childNodes
      @el.appendChild child

  setText: (text) ->
    textNode = @el.firstChild

    if !textNode
      @el.appendChild @el.ownerDocument.createTextNode text

    else if textNode.nodeType != TEXT_NODE
      @el.insertBefore @el.ownerDocument.createTextNode(text), textNode

    else
      textNode.nodeValue = text

  getText: ->
    (child.nodeValue for child in @childNodes when child.nodeType == TEXT_NODE).join ''

  setSelected: (value) ->
    value = value.toString()
    childElements = getElements @el
    for child in childElements
      if child.nodeName == 'option'
        if child.el.value == value
          child.el.selected = true
        else
          child.el.selected = false

  attr: (attribute, value) ->
    if @nodeName == 'select' and attribute == 'selected'
      @setSelected value

    else
      switch attribute
        when 'text'
          unless @isVoidElement
            @originalAttributes['text'] ?= @getText()
            @setText value

        when 'html'
          @originalAttributes['html'] ?= @el.innerHTML
          @setHtml value

        when 'class'
          @originalAttributes['class'] ?= @el.className
          @el.className = value

        else
          @el[attribute] = value
          if isBoolean value
            @originalAttributes[attribute] ?= @el.getAttribute(attribute) || false
            if value
              @el.setAttribute attribute, attribute
            else
              @el.removeAttribute attribute
          else
            @originalAttributes[attribute] ?= @el.getAttribute(attribute) || ""
            @el.setAttribute attribute, value.toString()

ELEMENT_NODE = 1
TEXT_NODE    = 3

# From http://www.w3.org/TR/html-markup/syntax.html: void elements in HTML
VOID_ELEMENTS = ['area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'input',
  'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr']

# IE8 <= fails to clone detached nodes properly, shim with jQuery
# jQuery.clone: https://github.com/jquery/jquery/blob/master/src/manipulation.js#L594
# jQuery.support.html5Clone: https://github.com/jquery/jquery/blob/master/src/support.js#L83
html5Clone = () -> document.createElement('nav').cloneNode(true).outerHTML != '<:nav></:nav>'
cloneNode  =
  if not document? or html5Clone()
    (node) -> node.cloneNode true
  else
    (node) ->
      cloned = Transparency.clone(node)
      if cloned.nodeType == ELEMENT_NODE
        cloned.removeAttribute expando
        for element in cloned.getElementsByTagName '*'
          element.removeAttribute expando
      cloned

# Minimal implementation of jQuery.data
#
#     // in console
#     > template = document.getElementById('template')
#     > data(template).hello = 'Hello World!'
#     > console.log(data(template).hello)
#     Hello World!
#
# Expanding DOM element with a JS object is generally unsafe.
# However, as references to expanded DOM elements are never lost, no memory leaks are introduced
# http://perfectionkills.com/whats-wrong-with-extending-the-dom/
expando = 'transparency'
data    = (element) -> element[expando] ||= {}

nullLogger    = () ->
consoleLogger = (messages...) -> console.log messages...
log           = nullLogger

# Mostly from https://github.com/documentcloud/underscore/blob/master/underscore.js
toString      = Object.prototype.toString
isDate        = (obj) -> toString.call(obj) == '[object Date]'
isDomElement  = (obj) -> obj.nodeType == ELEMENT_NODE
isPlainValue  = (obj) -> type = typeof obj; (type != 'object' and type != 'function') or isDate obj
isBoolean     = (obj) -> obj is true or obj is false
isArray       = Array.isArray || (obj) -> toString.call(obj) == '[object Array]'

(jQuery || Zepto)?.fn.render = Transparency.jQueryPlugin

if define?.amd then define -> Transparency
