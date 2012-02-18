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

  weld_t          = window.$("#weld")[0]
  transparency_t  = window.$("#transparency").get()
  mustache_t      = window.$("#mustache")[0]
  mustache_saved  = window.$("#mustache-saved").html()
  result          = window.$("#result")

  new window.Benchmark.Suite()
    .add("transparency", ->
      window.render transparency_t, data)

    .add("weld", ->
      window.weld weld_t, data)

    .add("mustache", ->
      mustache_t.innerHTML = window.Mustache.to_html(mustache_saved, data))

    .on("cycle", (event, bench) ->
      result.append String(bench) + '\n')

    .on("complete", ->
      result.append "Fastest is " + @filter("fastest").pluck("name") + "\n"
      result.trigger "complete")

    .run true
