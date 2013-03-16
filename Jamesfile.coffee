james      = require 'james'
coffee     = require 'james-coffee'
uglify     = require 'james-uglify'
browserify = require 'browserify'
coffeeify  = require 'coffeeify'
path       = require 'path'

james.task 'build', ->

  #Compile sources
  dist = james.write 'dist/transparency.js'
  min  = james.write 'dist/transparency.min.js'

  # [
  #   'src/helpers.coffee',  'src/transparency.coffee',     'src/context.coffee',
  #   'src/instance.coffee', 'src/attributeFactory.coffee', 'src/elementFactory.coffee'
  # ]
  # .forEach (filename) ->
  #   js = james.read(filename).transform coffee filename: filename

  #   js.write dist
  #   js.transform(uglify).write min

  src = james.list('src/**/*.coffee').map (filename) ->
    james.read(filename)
      .transform(coffee filename: filename, bare: true)
      .write filename.replace(/src/, 'dist').replace(/\.coffee$/, '.js')

  james.wait(src).then ->
    bundle = james.read(browserify('./dist/transparency.js').bundle())
    bundle.write dist
    bundle.transform(uglify).write min


#   # Compile tests
#   tests = james.list('spec/**/*.coffee').map (filename) ->

#     james.read(filename)
#       .transform(coffee filename: filename)
#       .write filename.replace /\.coffee$/, '.js'

james.task 'watch', ->

  james.watch 'src/**/*.coffee', -> james.run 'build'

james.task 'default', ['build']
