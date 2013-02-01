# **Transparency** is a client-side template engine, which binds JSON objects to DOM elements.
#
#     //  Template:
#     //
#     //  <ul id="todos">
#     //    <li class="todo"></li>
#     //  </ul>
#     template = document.querySelector('#todos');
#
#     data = [
#       {todo: "Eat"},
#       {todo: "Do some programming"},
#       {todo: "Sleep"}
#     ];
#
#     Transparency.render(template, data);
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
Transparency = {}

# `Transparency.render` maps JSON objects to DOM elements.
Transparency.render = (context, models = [], directives = {}, options = {}) ->
  # First, check if we are in debug mode and if so, log the args.
  log = if options.debug and console then consoleLogger else nullLogger
  log "Transparency.render:", context, models, directives, options
  return unless context

  # `models` may be a list of objects, or a single object.
  # It's easier to iterate if it is guaranteed to be a list :)
  models = [models] unless isArray models

  # Rendering is a lot faster when the `context` is detached from the DOM, as
  # we avoid excess reflow calculations. However, we need to save reference
  # to `parent` and `nextSibling` so we can put it back once we're done.
  parent = context.parentNode
  if parent
    sibling = context.nextSibling
    parent.removeChild context

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
  prepareContext context, models

  # In addition to creating and removing template instances, `prepareContext`
  # creates a data object attached on the `context` element. Data object has a list of template
  # `instances`, which is needed for rendering.
  instances = data(context).instances

  # Now, as we have a list of `models` and a list of template `instances`,
  # we are ready to render each `model` to the corresponding template `instance`.
  for model, index in models
    children = []
    instance = instances[index]

    # Automatic rendering covers the most common use cases, e.g.,
    # rendering text content, form input values and other DOM elements (i.e. Backbone Views).
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
            #
            #         <div class="todo">Do some OSS</todo>
            #
            #          <input name="todo" value="Do some OSS" />
            #
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

        # Rendering nested models breadth-first is more robust,
        # so let's just save the key of the child model and take care of it once
        # we're done with the parent model.
        else if typeof value == 'object'
          children.push key

    # Render directives
    renderDirectives instance, model, index, directives

    # Now, let's think about writing event handlers.
    # It would be great to have an access to the associated `model` when the user clicks
    # a todo element. That would save us from rendering `id` attributes by hand.
    #
    #     // Log the associated model to console.
    #     $('#todos').on('click', '.todo', function(e) {
    #       console.log(e.target.transparency.model);
    #     });
    #
    # That's easy, as we associate the `model` to each `element` in our template `instance`.
    data(e).model = model for e in instance.elements

    # As we are done with the plain values and directives, it's time to render the nested models, e.g.,
    #
    #     //  Template:
    #     //  <div id="person">
    #     //    <div class="name">
    #     //    <div class="address">
    #     //      <div class=""
    #     //  </div>
    #
    #     models = {
    #       name: "Batman",
    #       address: {
    #         street: "Unknown"
    #         city:   "Gotham"
    #       }
    #     };
    #
    # Here, recursion is our friend. Calling `Transparency.render`
    # for each matching `element` and passing on the corresponding data does the trick and
    # renders the nested models, e.g., `address` in the example above.
    for key in children
      for element in matchingElements instance, key
        Transparency.render element, model[key], directives[key], options

  # Finally, put `context` back to its original place in the DOM
  if parent
    if sibling
    then parent.insertBefore context, sibling
    else parent.appendChild context

  # and return it in order to support chaining.
  context

# ### Configuration

# Default element matcher. Returns `true`, in case the value associated with `key` should be rendered to this `element`.
# Override in case custom matching is needed.
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

# Shim for cloning nodes on oldIE. Override in case you need to support oldIE without jQuery.
#
#     Transparency.cloneFallback = myDeepCloneFunction
Transparency.clone = (node) -> (@jQuery || @Zepto).clone()[0]

# Register Transparency as a jQuery plugin.
#
#     $.fn.render = Transparency.jQueryPlugin;
#
#     // Render with jQuery
#     $('#template').render({hello: 'World'});
Transparency.jQueryPlugin = (models, directives, options) ->
  for context in this
    Transparency.render context, models, directives, options
  this


# ## Internals

# Internal functions and classes are not properly documented yet.

class Instance
  constructor: (@template) ->
    @queryCache = {}
    @elements   = []
    @childNodes = []
    getElementsAndChildNodes @template, @elements, @childNodes

prepareContext = (context, models) ->
  contextData = data context

  # Initialize context
  unless contextData.template
    contextData.template      = cloneNode context
    contextData.instanceCache = [] # Query-cached template instances are precious, save them for the future
    contextData.instances     = [new Instance(context)] # Currently used template instances
  log "Template", contextData.template

  # Get templates from the cache or clone new ones, if the cache is empty.
  while models.length > contextData.instances.length
    instance = contextData.instanceCache.pop() || new Instance(cloneNode contextData.template)
    (context.appendChild n for n in instance.childNodes)
    contextData.instances.push instance

  # Remove leftover templates from DOM and save them to the cache for later use.
  while models.length < contextData.instances.length
    contextData.instanceCache.push instance = contextData.instances.pop()
    (n.parentNode.removeChild n) for n in instance.childNodes

  # Reset templates before reuse
  for instance in contextData.instances
    for element in instance.elements
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

        value = directive.call model, element: element, index: index, value: attr element, attribute
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

  if element.nodeName.toLowerCase() == 'select' and attribute == 'selected'
    value = value.toString() if value? and typeof value != 'string'
    setSelected(element, value) if value?

  else switch attribute

    when 'text'
      unless isVoidElement element
        value = value.toString() if value? and typeof value != 'string'
        elementData.originalAttributes['text'] ?= getText element
        setText(element, value) if value?

    when 'html'
      value = value.toString() if value? and typeof value != 'string'
      elementData.originalAttributes['html'] ?= element.innerHTML
      setHtml(element, value) if value?

    when 'class'
      elementData.originalAttributes['class'] ?= element.className
      element.className = value if value?

    else
      if value?
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


  if value? then value else elementData.originalAttributes[attribute]

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
      cloned = cloneFallback(node)
      if cloned.nodeType == ELEMENT_NODE
        cloned.removeAttribute expando
        (element.removeAttribute expando) for element in cloned.getElementsByTagName '*'
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

(@jQuery || @Zepto)?.fn.render = Transparency.jQueryPlugin

if define?.amd
  define -> Transparency
else
  @Transparency = Transparency

