james      = require 'james'
coffee     = require 'james-coffee'
uglify     = require 'james-uglify'
browserify = require 'browserify'
Q          = require 'q'

james.task 'build', ->

  js = james.list('src/**/*.coffee', 'spec/**/*.coffee').map (filename) ->
    james.read(filename)
      .transform(coffee filename: filename)
      .write filename.replace /\.coffee$/, '.js'

  james.wait(js).then ->
    dist = james.read browserify('./src/transparency.js').bundle()

    dist.write                   'dist/transparency.js'
    dist.transform(uglify).write 'dist/transparency.min.js'

james.task 'watch', ->

  james.watch 'src/**/*.coffee', -> james.run 'build'

james.task 'default', ['build']
