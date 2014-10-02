gulp           = require 'gulp'
coffee         = require 'gulp-coffee'
uglify         = require 'gulp-uglify'
streamify      = require 'gulp-streamify'
mochaPhantomJS = require 'gulp-mocha-phantomjs'
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
    .pipe streamify uglify()
    .pipe gulp.dest './dist/transparency.min.js'

gulp.task 'test:functional', ->
  gulp
    .src  './spec/mocha.html'
    .pipe mochaPhantomJS()


gulp.task 'bundle',  ['compile']
gulp.task 'build',   ['compile:tests', 'bundle']
gulp.task 'test',    ['test:functional']
gulp.task 'default', ['build', 'test']


gulp.task 'watch', ->
  gulp.watch './**/*.coffee', ['build']
