jsdom = require 'jsdom'

jsdom.env
  html:"browser-nested-list.html"

  scripts: [
    'js/benchmark.js'
    'js/jquery-1.7.1.min.js'
    '../lib/transparency.js'
    'js/mustache.js'
    'js/weld.js'
    'js/nested-list.js'
  ]

  features:
    QuerySelector: true

  done: (errors, window) ->
    window.$(window.document).trigger "ready"

    window.$('#result').bind "complete", (event) ->
      console.log window.$('#result').text()