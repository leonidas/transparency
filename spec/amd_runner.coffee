require.config
  paths:
    jquery: 'lib/jquery-1.7.1.min'
  shim:
    jasmine: exports: 'jasmine'
    'jasmine-html': deps: ['jasmine']

require ['jquery', 'amd-spec'], ($)->
  $ ->
    jasmine.getEnv().addReporter new jasmine.HtmlReporter()
    jasmine.getEnv().execute()
