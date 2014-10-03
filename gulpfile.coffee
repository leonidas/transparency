gulp           = require 'gulp'
coffee         = require 'gulp-coffee'
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


gulp.task 'bundle', ->
  browserify entries: './lib/transparency.js'
    .bundle
    .pipe source './dist/transparency.js'
    .pipe uglify()
    .pipe gulp.dest './dist/transparency.min.js'


gulp.task 'test:functional', ->
  gulp
    .src  './spec/functionalSpecRunner.html'
    .pipe mochaPhantomJS()


gulp.task 'test:amd', ->
  gulp
    .src  './spec/amdSpecRunner.html'
    .pipe mochaPhantomJS()


gulp.task 'test:nodejs', ->
  gulp
    .src  './spec/serverSpec.js'
    .pipe mocha()


gulp.task 'test:performance', ->
  gulp
    .src  './spec/performanceSpecRunner.html'
    .pipe mochaPhantomJS()


gulp.task 'watch', ->
  gulp.watch './**/*.coffee', ['build', 'test']


gulp.task 'bundle',  ['compile']
gulp.task 'build',   ['compile:tests', 'bundle']
gulp.task 'test',    ['test:functional', 'test:amd', 'test:nodejs']
gulp.task 'release', ['build', 'test', 'test:performance']
gulp.task 'default', ['build', 'test', 'watch']
