_       = require '../lib/lodash.js'
helpers = require './helpers'
Context = require './context'

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
Transparency = {}

# `Transparency.render` maps JSON objects to DOM elements.
Transparency.render = (context, models = [], directives = {}, options = {}) ->
  # First, check if we are in debug mode and if so, log the arguments.
  log = if options.debug and console then helpers.consoleLogger else helpers.nullLogger
  log "Transparency.render:", context, models, directives, options

  return unless context
  models = [models] unless _.isArray models

  # Context element, state and functionality is wrapped to `Context` object. Get it, or create a new
  # if it doesn't exist yet.
  context = helpers.data(context).context ||= new Context(context, Transparency)

  # Rendering is a lot faster when the context element is detached from the DOM, as
  # reflow calculations are not triggered. So, detach it before rendering.
  context.render(models, directives, options).el

# ### Configuration

# By default, Transparency matches model properties to elements by `id`, `class`, `name` and `data-bind` attributes.
# Override `Transparency.matcher` to change the default behavior.
#
#     // Match only by `data-bind` attribute
#     Transparency.matcher = function (element, key) {
#       element.el.getAttribute('data-bind') == key;
#     };
#
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
#
Transparency.clone = (node) ->
  $(node).clone()[0]

# ### Exports

# In order to use Transparency as a jQuery plugin, add Transparency.jQueryPlugin to jQuery.fn object.
#
#     $.fn.render = Transparency.jQueryPlugin;
#
#     // Render with jQuery
#     $('#template').render({hello: 'World'});
#
Transparency.jQueryPlugin = helpers.chainable (models, directives, options) ->
  for context in this
    Transparency.render context, models, directives, options

# Register Transparency, if jQuery or Zepto is defined
if (jQuery? || Zepto?)
  $ = jQuery || Zepto
  $?.fn.render = Transparency.jQueryPlugin

# Exports for node.js, browser global and AMD
if module?.exports then module.exports      = Transparency
if window?         then window.Transparency = Transparency
if define?.amd     then define -> Transparency
