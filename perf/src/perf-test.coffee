window.$(window.document).bind "ready", ->
  data =
    name: "Joshua Kehn"
    interests: [
      interest: "javascript"
    ,
      interest: "node.js"
    ,
      interest: "development"
    ,
      interest: "programming"
    ]

  weld_t          = window.$("#weld")
  transparency_t  = window.$("#transparency")
  mustache_t      = window.$("#mustache")
  mustache_saved  = window.$("#mustache-saved")
  result          = window.$("#result")

  new window.Benchmark.Suite()
    .add("transparency", ->
      transparency_t.render data)

    .add("weld", ->
      window.weld weld_t[0], data)

    .add("mustache", ->
      mustache_t.html window.Mustache.to_html(mustache_saved.html(), data))

    .on("cycle", (event, bench) ->
      result.append String(bench) + '\n')

    .on("complete", ->
      result.append "Fastest is " + @filter("fastest").pluck("name"))

    .run true