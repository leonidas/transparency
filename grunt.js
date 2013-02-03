/*global module:false*/
module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: '<json:package.json>',

    meta: {
      banner:
        '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - ' +
        '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
        '<%= pkg.homepage ? "* " + pkg.homepage + "\n" : "" %>' +
        '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author %>;' +
        ' Licensed <%= pkg.licenses.join(", ") %> */'
    },

    coffee: {
      compile: {
        files: {
          'dist/*.js': 'src/**/*.coffee',
          'spec/*.js': 'spec/**/*.coffee'
        }
      }
    },

    jasmine: {
      all: {
        src: ['spec/*.html'],
        errorReporting: true
      }
    },

    min: {
      dist: {
        src: ['<banner:meta.banner>', 'dist/transparency.js'],
        dest: 'dist/transparency.min.js'
      }
    },

    watch: {
      files: ['src/**/*.coffee', 'spec/**/*.coffee'],
      tasks: ['coffee', 'jasmine', 'min', 'docco']
    },

    docco: {
      src: ['src/**/*.coffee'],
      dest: 'docs/'
    }
  });

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-jasmine-task');
  grunt.loadNpmTasks('grunt-docco');

  // Default task.
  grunt.registerTask('default', ['coffee', 'jasmine', 'min', 'docco', 'watch']);
  grunt.registerTask('test',    ['coffee', 'jasmine']);

};
