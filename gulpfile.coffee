gulp           = require 'gulp'
coffee         = require 'gulp-coffee'
streamify      = require 'gulp-streamify'
uglify         = require 'gulp-uglify'
mochaPhantomJS = require 'gulp-mocha-phantomjs'
mocha          = require 'gulp-mocha'
source         = require 'vinyl-source-stream'
browserify     = require 'browserify'

gulp.task 'compile', ->
  gulp
    .src  './src/*.coffee'
    .pipe coffee bare: true
    .pipe gulp.dest './lib/'


gulp.task 'compile:tests', ->
  gulp
    .src  './spec/**/*.coffee'
    .pipe coffee()
    .pipe gulp.dest './spec/'


gulp.task 'bundle', ['compile'], ->
  bundle = browserify entries: './lib/transparency.js'
    .bundle()

  bundle
    .pipe source 'transparency.js'
    .pipe gulp.dest './dist/'

  bundle
    .pipe source 'transparency.min.js'
    .pipe streamify uglify()
    .pipe gulp.dest './dist/'


gulp.task 'test:functional', ['compile:tests'], ->
  gulp
    .src  './spec/functionalSpecRunner.html'
    .pipe mochaPhantomJS()


gulp.task 'test:amd', ['compile:tests'], ->
  gulp
    .src  './spec/amdSpecRunner.html'
    .pipe mochaPhantomJS()


gulp.task 'test:nodejs', ['compile:tests'], ->
  gulp
    .src  './spec/serverSpec.js'
    .pipe mocha()


gulp.task 'test:performance', ['compile:tests'], ->
  gulp
    .src  './spec/performanceSpecRunner.html'
    .pipe mochaPhantomJS()


gulp.task 'watch', ->
  gulp.watch './**/*.coffee', ['bundle', 'test']


gulp.task 'test',    ['bundle', 'test:functional', 'test:amd', 'test:nodejs']
gulp.task 'release', ['bundle', 'test', 'test:performance']
gulp.task 'default', ['bundle', 'test', 'watch']
