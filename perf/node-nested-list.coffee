jsdom = require 'jsdom'

jsdom.env "browser-perf.html", [
    'js/benchmark.js'
    'js/jquery-1.7.1.min.js'
    '../lib/transparency.js'
    'js/mustache.js'
    'js/weld.js'
    'js/perf-test.js'
  ],
  (errors, window) ->
    window.$(window.document).trigger "ready"

    n = 1
    window.$('#result').bind "complete", (event) ->
      console.log window.$('#result').text()

