
module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    banner: """
      ###!
      * <%= pkg.title || pkg.name %> - v<%= pkg.version %> - <%= grunt.template.today("yyyy-mm-dd") %>
      * <%= pkg.homepage %>
      * Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author %>; Licensed <%= pkg.licenses.join(", ") %>
      ###\n\n
      """

    concat:
      options:
        banner: '<%= banner %>'
      coffee:
        src: ['src/helpers.coffee', 'src/transparency.coffee', 'src/context.coffee',
              'src/instance.coffee', 'src/attributeFactory.coffee', 'src/elementFactory.coffee']
        dest: '.tmp/transparency.coffee'

    coffee:
      compile:
        files: [
          src: '.tmp/transparency.coffee'
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
          vendor: ['spec/lib/jquery-1.9.1.min.js']
          specs:  ['spec/*Spec.js', '!spec/performance*', '!spec/amd*']
          helpers: 'spec/specHelper.js'

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

    uglify:
      options:
        preserveComments: 'some'
      files:
        src: 'dist/transparency.js'
        dest: 'dist/transparency.min.js'

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

  grunt.registerTask 'build',       ['concat', 'coffee', 'uglify', 'docco']
  grunt.registerTask 'tdd',         ['build', 'jasmine:functional', 'jasmine:amd', 'jasmine:nojQuery']
  grunt.registerTask 'test',        ['coffee', 'jasmine']
  grunt.registerTask 'build-tests', ['jasmine:functional:build', 'jasmine:amd:build', 'jasmine:performance:build']
  grunt.registerTask 'default',     ['build', 'tdd', 'build-tests']


