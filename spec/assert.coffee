trim = (text) ->
  text.replace(/\s/g, '').toLowerCase()

expect = (actual) ->
  toBeEqual: (expected) ->
    unless trim(actual.text()) == trim(expected.text())
      throw new Error "ERROR: '#{actual.text()}' is not equal to '#{expected.text()}'"

    for attribute in expected[0].attributes
      actualAttr   = actual[0].getAttribute attribute.name
      throw new Error "ERROR: Missing expected attribute '#{attribute.name}'" unless actualAttr?

      actualAttr   = trim actualAttr
      expectedAttr = trim expected[0].getAttribute attribute.name

      unless actualAttr == expectedAttr
        throw new Error "ERROR: '#{attribute.name}=\"#{actualAttr}\"' is not equal to '#{expectedAttr}\"'"

    actualChildren   = actual.children()
    expectedChildren = expected.children()

    if expectedChildren.length != actualChildren.length
      throw new Error "Expected children count #{expectedChildren.length} is not equal to actual children count #{actualChildren.length}"

    for child, i in expectedChildren
      expect($(actualChildren[i])).toBeEqual $(child)

  toEqual: (expected) ->
    throw new Error "#{actual} != #{expected}" unless actual == expected

  toBeOnTheSameBallpark: (expected, ballpark) ->
      message =
        "Expected #{actual.name} (#{actual.stats.mean} +/- #{actual.stats.moe} to be less than " +
        "#{ballpark} x #{expected.name} (#{expected.stats.mean} +/- #{expected.stats.moe}"

      console.log actual.toString()
      console.log expected.toString()
      passed = actual.stats.mean + actual.stats.moe < ballpark * expected.stats.mean + actual.stats.moe

      throw new Error message unless passed

  toBeDefined: -> throw Error "Variable not defined: #{actual}" unless actual?

@expect = expect
