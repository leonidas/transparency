{exec} = require 'child_process'

task 'build', 'compile and uglify transparency', (options) ->
  exec([
    "coffee -o lib -c src/jquery.transparency.coffee"
    "uglifyjs lib/jquery.transparency.js > lib/jquery.transparency.min.js"
  ].join(' && '), (err, stdout, stderr) ->
    if err then console.log stderr.trim()
  )