jsdom = require 'jsdom'

jsdom.env "perf-test.html", [
    'js/benchmark.js'
    'js/jquery-1.7.1.min.js'
    'js/mustache.js'
    'js/weld.js'
    '../lib/jquery.transparency.js'
  ],
  (errors, window) ->
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

    weld_t           = window.$("#weld")
    transparency_t   = window.$("#transparency")
    mustache_t       = window.$("#mustache")
    mustache_saved   = window.$("#mustache-saved")

    console.log 'foo'
    suite = new window.Benchmark.Suite()
    console.log 'foo'
    suite
      .add("transparency", ->
        transparency_t.render data)

      .add("weld", ->
        window.weld weld_t[0], data)

      .add("mustache", ->
        mustache_t.html window.Mustache.to_html(mustache_saved.html(), data))

      .on("cycle", (event, bench) ->
        console.log String(bench))

      .on("complete", ->
        console.log "Fastest is " + @filter("fastest").pluck("name"))

      .run true

