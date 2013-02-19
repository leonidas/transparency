
module.exports = (grunt) ->

  grunt.initConfig
    coffee:
      compile:
        files: [
          src: 'src/transparency.coffee'
          dest: 'dist/transparency.js'
        ,
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
          vendor: ['spec/lib/jquery-1.7.1.min.js']
          specs:  ['spec/*Spec.js', '!spec/performance*', '!spec/amd*']
          helpers: 'spec/specHelper.js'

      performance:
        src: 'dist/transparency.js'
        options:
          outfile: 'PerformanceSpecRunner.html'
          vendor: ['spec/lib/jquery-1.7.1.min.js', 'spec/lib/benchmark.js', 'spec/lib/handlebars.js']
          specs:  ['spec/performanceSpec.js']
          helpers: 'spec/specHelper.js'

      amd:
        src: 'dist/transparency.js'
        options:
          outfile: 'AmdSpecRunner.html'
          vendor: ['spec/lib/jquery-1.7.1.min.js']
          specs: ['spec/amdSpec.js']
          helpers: 'spec/specHelper.js'
          template: require('grunt-template-jasmine-requirejs')

    uglify:
      files:
        'dist/transparency.min.js': 'dist/transparency.js'

    watch:
      files: ['src/**/*.coffee', 'spec/**/*.coffee']
      tasks: ['default']

    docco:
      docs:
        src: ['src/**/*.coffee']
        dest: 'docs/'

  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-docco'

  grunt.registerTask 'default', ['coffee',
    'jasmine:functional', 'jasmine:amd',
    'jasmine:functional:build', 'jasmine:amd:build', 'jasmine:performance:build',
  'uglify', 'docco']

  grunt.registerTask 'test', ['coffee', 'jasmine']
