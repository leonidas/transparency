jQuery?.fn.render = (models, directives) ->
  Transparency.render this.get(), models, directives
  this

@Transparency    = Transparency = {}
module?.exports  = Transparency

Transparency.render = (contexts, models, directives) ->
  return unless contexts
  models     ||= []
  directives ||= {}
  # Context may be NodeList. Clone it to Array
  contexts     = if contexts.length? and contexts[0] then (c for c in contexts) else [contexts]
  models       = [models] unless Array.isArray models

  for context in contexts
    # DOM manipulation is a lot faster when elements are detached. Save the original position, so we can put the context back to it's place.
    sibling = context.nextSibling
    parent  = context.parentNode
    parent?.removeChild context

    # Make sure we have right amount of template instances available
    prepareContext context, models

    # Render each model to its template instance
    for model, index in models
      instance = context.transparency.instances[index]

      # Associate model with instance elements
      for e in instance.elements
        e.transparency.model = model

      renderValues      instance, model
      renderDirectives  instance, model, directives, index
      renderChildren    instance, model, directives

    # Finally, put the context element back to it's original place in DOM
    if sibling then parent?.insertBefore(context, sibling) else parent?.appendChild context
  return contexts

prepareContext = (context, models) ->
  # Extend context element with transparency hash to store the template elements and cached instances
  context.transparency                ||= {}
  context.transparency.template       ||= (context.removeChild context.firstChild while context.firstChild)
  context.transparency.templateCache  ||= [] # Query-cached templates are precious, so save them for the future
  context.transparency.instances      ||= [] # Currently used template instances

  # Get templates from the cache or clone new ones, if the cache is empty.
  while models.length > context.transparency.instances.length
    instance = context.transparency.templateCache.pop() ||
      {
        queryCache: {}
        template:   (template = (n.cloneNode true for n in context.transparency.template))
        elements:   elementNodes template
      }
    (context.appendChild n) for n in instance.template
    context.transparency.instances.push instance

  # Remove leftover templates from DOM and save them to the cache for later use.
  while models.length < context.transparency.instances.length
    context.transparency.templateCache.push instance = context.transparency.instances.pop()
    (n.parentNode.removeChild n) for n in instance.template

  # Return the original attribute values
  for instance in context.transparency.instances
    for e in instance.elements
      (e.setAttribute attr, value) for attr, value of e.transparency.attributes

renderValues = (instance, model) ->
  if typeof model == 'object'
    for key, value of model when (typeof value != 'object' && typeof value != 'function')
      setText(element, value) for element in matchingElements(instance, key)
  else
    element = matchingElements(instance, 'listElement')[0] || instance.elements[0]
    setText(element, model) if element

renderDirectives = (instance, model, directives, index) ->
  renderFunctionDirectives instance, model, directives, index
  renderObjectDirectives instance, model, directives, index

renderFunctionDirectives = (instance, model, directives, index) ->
  for key, directiveFunction of directives when typeof directiveFunction == 'function'

    for element in matchingElements(instance, key)
      directive = directiveFunction.call(model, element, index)

      if not directive
        # Directive function returned no value, meaning
        # it most likely did element in-place manipulation
        # on element parameter
        continue

      directive = text: directive if typeof directive == 'string'

      setText element, directive.text
      setHtml element, directive.html

      for attr, value of directive when attr != 'html' and attr != 'text'

        # Save the original attribute value for the instance reuse

        element.transparency.attributes       ||= {}
        element.transparency.attributes[attr] ||= element.getAttribute attr
        element.setAttribute attr, value

renderObjectDirectives = (instance, model, directives, index) ->

  # Support object like directives
  for key, directive of directives when typeof directive == 'object'

    for element in matchingElements(instance, key)

        # Handle element body value setting
        if directive.text
          setText element, directive.text.call(model, element, index)

        if directive.html
          value = directive.htmt.call(model, element, index)
          if value
            # html() is allowed to do in-place manipulation
            setHtml element, value

        for attr, value of directive when attr != 'html' and attr != 'text'

          if typeof value == 'object'
            # Nested directive, recurse into the matched object
            renderObjectDirectives element, model, value, index
            continue

          # Do attribute function set/call
          if typeof value == 'string'
            # Input given as fixed string
          else if typeof value == 'function'
            srcValue = element.getAttribute attr
            value = value.call(model, srcValue, index)
          else
            throw new Error "Unknown nested directive"

          element.setAttribute attr, value

renderChildren = (instance, model, directives) ->
  for key, value of model when typeof value == 'object'
    Transparency.render element, value, directives[key] for element in matchingElements(instance, key)

setContent = (callback) ->
  (e, content) ->
    return if !e or !content? or e.transparency.content == content
    e.transparency.content    = content
    e.transparency.children ||= (n for n in e.childNodes when n.nodeType == ELEMENT_NODE)

    (e.removeChild e.firstChild) while e.firstChild
    callback e, content
    (e.appendChild c) for c in e.transparency.children

setHtml = setContent (e, html) -> e.innerHTML = html
setText = setContent (e, text) ->
  if e.nodeName.toLowerCase() == 'input'
    e.setAttribute 'value', text
  else
    e.appendChild e.ownerDocument.createTextNode text

matchingElements = (instance, key) ->
  instance.queryCache[key] ||= (e for e in instance.elements when elementMatcher e, key)

elementNodes = (template) ->
  elements = []
  for e in template when e.nodeType == ELEMENT_NODE
    e.transparency ||= {}
    elements.push e
    for child in e.getElementsByTagName '*'
      child.transparency ||= {}
      elements.push child
  elements

elementMatcher = (element, key) ->
  element.id                        == key               ||
  element.className.split(' ').indexOf(key) > -1         ||
  element.name                      == key               ||
  element.nodeName.toLowerCase()    == key.toLowerCase() ||
  element.getAttribute('data-bind') == key

ELEMENT_NODE = 1

# Browser compatibility
Array::indexOf ?= (s) ->
  index = -1
  for x, i in this when x == s
    index = i
    break
  index

# http://perfectionkills.com/instanceof-considered-harmful-or-how-to-write-a-robust-isarray/
Array.isArray ?= (ob) ->
  Object.prototype.toString.call(ob) == '[object Array]'

