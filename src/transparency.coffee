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

  # `models` may be a list of objects, or a single object.
  # It's easier to iterate if it is guaranteed to be a list :)
  models = [models] unless isArray models

  # Rendering is a lot faster when the `context` is detached from the DOM, as
  # reflow calculations are not triggered. However, we need to save reference
  # to `parent` and `nextSibling` in order to attach the `context` back once we're done.
  context = data(context).context ||= new Context(context)
  context.detach()

  # Next, we need to make sure there's a right amount of template instances available.
  # For example, if our `models` is a list of three todo items and the `context` is
  #
  #     <ul "id=todos">
  #       <li class="todo"></li>
  #     </ul>
  #
  # two template `instances` needs to be appended to the `context` before rendering.
  #
  #     <ul "id=todos">
  #       <li class="todo"></li>
  #       <li class="todo"></li>
  #       <li class="todo"></li>
  #     </ul>
  context.prepare models

  # `prepareContext` stores the state of the `context` to a data object.
  # From the data object, the list of template `instances` is needed for rendering.

  # Now, having a list of `models` and a list of template `instances`,
  # we are ready to render each `model` to the corresponding template `instance`.
  for model, index in models
    children = []
    instance = context.instances[index]

    # First, let's think about writing event handlers.
    # For example, it would be convenient to have an access to the associated `model`
    # when the user clicks a todo element. No need to set `data-id` attributes or other
    # identifiers manually \o/
    #
    #     $('#todos').on('click', '.todo', function(e) {
    #       console.log(e.target.transparency.model);
    #     });
    #
    for e in instance.elements
      data(e).model = model

    # Next, take care of default rendering, which covers the most common use cases like
    # setting text content, form values and DOM elements (.e.g., Backbone Views).
    # Rendering as a text content is a safe default, as it is HTML escaped
    # by the browsers.
    if isDomElement(model) and element = instance.elements[0]
      empty(element).appendChild model

    else if typeof model == 'object'
      for own key, value of model when value?

        # The value can be either a nested model or a plain value, i.e., `Date`, `string`, `boolean` or `double`.
        # Start by handling the plain values and finding the matching elements.
        if isPlainValue value
          for element in matchingElements instance, key

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
            nodeName = element.nodeName.toLowerCase()
            if nodeName == 'input'
              attr element, 'value', value
            else if nodeName == 'select'
              attr element, 'selected', value
            else attr element, 'text',  value

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
    renderDirectives instance, model, index, directives

    # As we are done with the plain values and directives, it's time to render the nested models.
    # Here, recursion is our friend. Calling `Transparency.render` for each child model and matching `element`
    # does the trick and renders the nested models.
    for key in children
      for element in matchingElements instance, key
        Transparency.render element, model[key], directives[key], options

  # Finally, put `context` back to its original place in the DOM
  # and return it in order to support chaining.
  context.attach()

  context.el

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
  element.id                        == key        ||
  indexOf(element.className.split(' '), key) > -1 ||
  element.name                      == key        ||
  element.getAttribute('data-bind') == key

# IE6-8 fails to clone nodes properly. By default, Transparency uses jQuery.clone() as a shim.
# Override `Transparency.clone` with a custom clone function, if oldIE needs to be
# supported without jQuery.
#
#     Transparency.clone = myCloneFunction;
Transparency.clone = (node) -> (jQuery || Zepto)?(node).clone()[0]

# ## Internals

class Context
  constructor: (@el) ->
    @template      = cloneNode @el
    @instances     = [new Instance(@el, @el)]
    @instanceCache = []
    @parent        = @el.parentNode

    if @parent
      @nextSibling = @el.nextSibling

  detach: -> @parent.removeChild @el

  attach: ->
    if @parent
      if @nextSibling
      then @parent.insertBefore @el, @nextSibling
      else @parent.appendChild @el

  prepare: (models) ->
    # Get templates from the cache or clone new ones, if the cache is empty.
    while models.length > @instances.length
      instance = @instanceCache.pop() || new Instance(@el, cloneNode @template)
      @instances.push instance.appendToContext()

    # Remove leftover templates from DOM and save them to the cache for later use.
    while models.length < @instances.length
      @instanceCache.push @instances.pop().remove()

    # Reset templates before reuse
    for instance in @instances
      instance.reset()

# For each model we are about to render, there needs to be a template `instance`.
# Instance object keeps track of DOM nodes, elements and has a local query selector
# cache.
class Instance
  constructor: (@context, @template) ->
    @queryCache = {}
    @elements   = []
    @childNodes = []
    getElementsAndChildNodes @template, @elements, @childNodes

  remove: ->
    for n in @childNodes
      @context.removeChild n
    this

  appendToContext: ->
    for n in @childNodes
      @context.appendChild n
    this

  reset: ->
    for element in @elements
      for attribute, value of data(element).originalAttributes
        attr element, attribute, value


getElementsAndChildNodes = (template, elements, childNodes) ->
  child = template.firstChild
  while child
    childNodes?.push child

    if child.nodeType == ELEMENT_NODE
      data(child).originalAttributes ||= {}
      elements.push child
      getElementsAndChildNodes child, elements

    child = child.nextSibling

renderDirectives = (instance, model, index, directives) ->
  return unless directives
  model = if typeof model == 'object' then model else value: model

  for own key, attributes of directives when typeof attributes == 'object'
    for element in matchingElements instance, key
      for attribute, directive of attributes when typeof directive == 'function'

        value = directive.call model,
          element: element
          index:   index
          value:   attr element, attribute

        attr element, attribute, value

setHtml = (element, html) ->
  elementData = data element
  return if elementData.html == html

  elementData.html       = html
  elementData.children ||= (n for n in element.childNodes when n.nodeType == ELEMENT_NODE)

  empty element
  element.innerHTML = html
  element.appendChild child for child in elementData.children

setText = (element, text) ->
  elementData = data element
  return if !text? or elementData.text == text

  elementData.text = text
  textNode         = element.firstChild

  if !textNode
    element.appendChild element.ownerDocument.createTextNode text

  else if textNode.nodeType != TEXT_NODE
    element.insertBefore element.ownerDocument.createTextNode(text), textNode

  else
    textNode.nodeValue = text

getText = (element) ->
  (child.nodeValue for child in element.childNodes when child.nodeType == TEXT_NODE).join ''

setSelected = (element, value) ->
  value = value.toString()
  childElements = []
  getElementsAndChildNodes element, childElements
  for child in childElements
    if child.nodeName.toLowerCase() == 'option'
      if child.value == value
        child.selected = true
      else
        child.selected = false

attr = (element, attribute, value) ->
  elementData = data element
  return elementData.originalAttributes[attribute] unless value?

  if element.nodeName.toLowerCase() == 'select' and attribute == 'selected'
    setSelected element, value

  else
    switch attribute
      when 'text'
        unless isVoidElement element
          elementData.originalAttributes['text'] ?= getText element
          setText element, value

      when 'html'
        elementData.originalAttributes['html'] ?= element.innerHTML
        setHtml element, value

      when 'class'
        elementData.originalAttributes['class'] ?= element.className
        element.className = value

      else
        element[attribute] = value
        if isBoolean value
          elementData.originalAttributes[attribute] ?= element.getAttribute(attribute) || false
          if value
            element.setAttribute attribute, attribute
          else
            element.removeAttribute attribute
        else
          elementData.originalAttributes[attribute] ?= element.getAttribute(attribute) || ""
          element.setAttribute attribute, value.toString()

matchingElements = (instance, key) ->
  elements = instance.queryCache[key] ||= (e for e in instance.elements when Transparency.matcher e, key)
  log "Matching elements for '#{key}':", elements
  elements

empty = (element) ->
  element.removeChild child while child = element.firstChild
  element

ELEMENT_NODE  = 1
TEXT_NODE     = 3

# From http://www.w3.org/TR/html-markup/syntax.html: void elements in HTML
VOID_ELEMENTS = ["area", "base", "br", "col", "command", "embed", "hr", "img", "input", "keygen", "link", "meta", "param", "source", "track", "wbr"]

# IE8 <= fails to clone detached nodes properly, shim with jQuery
# jQuery.clone: https://github.com/jquery/jquery/blob/master/src/manipulation.js#L594
# jQuery.support.html5Clone: https://github.com/jquery/jquery/blob/master/src/support.js#L83
html5Clone = () -> document.createElement("nav").cloneNode(true).outerHTML != "<:nav></:nav>"
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

expando = 'transparency'
data    = (element) ->
  # Expanding DOM element with a JS object is generally unsafe.
  # However, as references to expanded DOM elements are never lost, no memory leaks are introduced
  # http://perfectionkills.com/whats-wrong-with-extending-the-dom/
  element[expando] ||= {}

nullLogger    = () ->
consoleLogger = (messages...) -> console.log messages...
log           = nullLogger

# Mostly from https://github.com/documentcloud/underscore/blob/master/underscore.js
toString      = Object.prototype.toString
isDate        = (obj) -> toString.call(obj) == '[object Date]'
isDomElement  = (obj) -> obj.nodeType == ELEMENT_NODE
isVoidElement = (el)  -> indexOf(VOID_ELEMENTS, el.nodeName.toLowerCase()) > -1
isPlainValue  = (obj) -> isDate(obj) or typeof obj != 'object' and typeof obj != 'function'
isBoolean     = (obj) -> obj is true or obj is false
isArray       = Array.isArray || (obj) -> toString.call(obj) == '[object Array]'
indexOf       = (array, item) ->
  return array.indexOf(item) if array.indexOf
  for x, i in array
    if x == item then return i
  -1

(jQuery || Zepto)?.fn.render = Transparency.jQueryPlugin

if define?.amd then define -> Transparency
