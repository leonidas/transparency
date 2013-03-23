
module.exports = (grunt) ->

  grunt.initConfig
    coffee:
      compile:
        files: [
          expand: true
          cwd: 'spec'
          src: '**/*.coffee'
          dest: 'spec'
          ext: '.js'
        ]

    jasmine:
      functional:
        src: 'dist/transparency.js'
        options:
          outfile: 'FunctionalSpecRunner.html'
          vendor: ['spec/lib/jquery-1.9.1.min.js']
          specs:  ['spec/!(amd*|performance*|browserGlobal*|nojQuery*|server*)Spec.js']
          helpers: ['spec/specHelper.js', 'spec/lib/jasmine.tap_reporter.js']

      performance:
        src: 'dist/transparency.js'
        options:
          outfile: 'PerformanceSpecRunner.html'
          vendor: ['spec/lib/jquery-1.9.1.min.js', 'spec/lib/benchmark.js', 'spec/lib/handlebars.js']
          specs:  ['spec/performanceSpec.js']
          helpers: 'spec/specHelper.js'

      nojQuery:
        src: 'dist/transparency.js'
        options:
          outfile: 'NoJQuerySpecRunner.html'
          specs: ['spec/nojQuerySpec.js']
          helpers: 'spec/specHelper.js'
          template: require('grunt-template-jasmine-requirejs')

      amd:
        src: 'dist/transparency.js'
        options:
          outfile: 'AmdSpecRunner.html'
          vendor: ['spec/lib/jquery-1.9.1.min.js']
          specs: ['spec/amdSpec.js']
          helpers: 'spec/specHelper.js'
          template: require('grunt-template-jasmine-requirejs')

    watch:
      files: ['src/**/*.coffee', 'spec/**/*.coffee']
      tasks: ['default']


  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'

  grunt.registerTask 'build',       ['coffee']
  grunt.registerTask 'tdd',         ['build', 'jasmine:functional', 'jasmine:amd', 'jasmine:nojQuery']
  grunt.registerTask 'test',        ['coffee', 'jasmine']
  grunt.registerTask 'build-tests', ['jasmine:functional:build', 'jasmine:amd:build', 'jasmine:performance:build']
  grunt.registerTask 'default',     ['build', 'tdd', 'build-tests']


