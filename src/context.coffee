{before, after, chainable, cloneNode} = require './helpers'
Instance = require './instance'

# **Context** stores the original `template` elements and is responsible for creating,
# adding and removing template `instances` to match the amount of `models`.
module.exports = class Context

  detach = chainable ->
    @parent = @el.parentNode
    if @parent
      @nextSibling = @el.nextSibling
      @parent.removeChild @el

  attach = chainable ->
    if @parent
      if @nextSibling
      then @parent.insertBefore @el, @nextSibling
      else @parent.appendChild @el

  constructor: (@el, @Transparency) ->
    @template      = cloneNode @el
    @instances     = [new Instance(@el, @Transparency)]
    @instanceCache = []

  render: \
    before(detach) \
    after(attach) \
    chainable \
    (models, directives, options) ->

      # Cloning DOM elements is expensive, so save unused template `instances` and reuse them later.
      while models.length < @instances.length
        @instanceCache.push @instances.pop().remove()

      # DOM elements needs to be created before rendering
      # https://github.com/leonidas/transparency/issues/94
      while models.length > @instances.length
        instance = @instanceCache.pop() || new Instance(cloneNode(@template), @Transparency)
        @instances.push instance.appendTo(@el)

      for model, index in models
        instance = @instances[index]

        children = []
        instance
          .prepare(model, children)
          .renderValues(model, children)
          .renderDirectives(model, index, directives)
          .renderChildren(model, children, directives, options)
