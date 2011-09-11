##############################
# Boiler plate for Express
##############################

# Module dependencies.
express = require('express')
app     = module.exports = express.createServer()

# Configuration
app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use(require('stylus').middleware({ src: __dirname + '/public' }))
  app.use app.router
  app.use express.static(__dirname + "/public")

app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

app.configure "production", ->
  app.use express.errorHandler()

##############################
# Here's the fun part
##############################

# Database =)
database = {}
database.articles = [
      name: 'First Article'
      'name@href': "#articles/1"
    ,
      name: 'Second Article'
      'name@href': "#articles/2"
    ,
      name: 'Third Article'
      'name@href': "#articles/3"
    ]

# Routes
app.get "/.:format?", (req, res) ->
  if req.params.format == "json"
    res.send database.articles
  else
    res.render "index"

app.get "/articles/*", (req, res) ->
  res.render "index"

app.listen 3000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
