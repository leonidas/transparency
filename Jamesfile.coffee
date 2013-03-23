james      = require 'james'
coffee     = require 'james-coffee'
uglify     = require 'james-uglify'
browserify = require 'browserify'
coffeeify  = require 'coffeeify'

james.task 'build', ->

  dist = james.read browserify('./src/transparency.coffee')
    .transform(coffeeify)
    .bundle()

  dist.write                   'dist/transparency.js'
  dist.transform(uglify).write 'dist/transparency.min.js'

  james.list('spec/**/*.coffee').map (filename) ->
    james.read(filename)
      .transform(coffee filename: filename)
      .write filename.replace /\.coffee$/, '.js'

james.task 'watch', ->

  james.watch '*/**/*.coffee', -> james.run 'build'

james.task 'default', ['build']
