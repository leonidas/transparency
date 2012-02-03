jsdom = require 'jsdom'

jsdom.env "browser-perf.html", [
    'js/benchmark.js'
    'js/jquery-1.7.1.min.js'
    '../lib/jquery.transparency.js'
    'js/mustache.js'
    'js/weld.js'
    'js/perf-test.js'
  ],
  (errors, window) ->
    window.$(window.document).trigger("ready");
    console.log errors
    console.log window.$('#result').text()

