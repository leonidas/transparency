var env = jasmine.getEnv();
env.addReporter(new jasmine.TapReporter());
env.addReporter(new jasmine.HtmlReporter());
env.execute();
