Benchmark     = require "benchmark"
Mustache      = require "mustache"
Plates        = require "plates"
global.jQuery = require "jquery"
{weld}        = require "weld"
require "../lib/jquery.transparency"


page = jQuery('
<div>
  <div id="transparency">
    <h1 id="name">My Name</h1>
    <ul class="interests"><li class="interest">An interest</li></ul>
  </div>

  <div id="weld">
    <h1 id="name">My Name</h1>
    <ul class="interests"><li class="interest">An interest</li></ul>
  </div>

  <div id="mustache">
     <h1>{{name}}</h1>
     <ul>
     {{#interests}}
       <li>{{interest}}</li>
     {{/interests}}
     </ul>
  </div>

  <div id="mustache-saved">
     <h1>{{name}}</h1>
     <ul>
     {{#interests}}
       <li>{{interest}}</li>
     {{/interests}}
     </ul>
  </div>
</div>
')

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

weld_t           = page.find "#weld"
transparency_t   = page.find "#transparency"
mustache_t       = page.find "#mustache"
mustache_saved   = page.find "#mustache-saved"

suite = new Benchmark.Suite()

suite
  .add("transparency", ->
    transparency_t.render data)

  .add("weld", ->
    weld weld_t[0], data)

  .add("mustache", ->
    mustache_t.html Mustache.to_html(mustache_saved.html(), data))

  .on("cycle", (event, bench) ->
    console.log String(bench))

  .on("complete", ->
    console.log page.html()
    console.log "Fastest is " + @filter("fastest").pluck("name"))

  .run true
