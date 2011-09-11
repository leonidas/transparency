##############################
# Boiler plate for Express
##############################

# Module dependencies.
express = require 'express'
app     = module.exports = express.createServer()

# Configuration
app.configure ->
  app.use express.logger('dev')
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
      title: 'First Article'
      'title@href': "/articles/1"
      body: 'Hello World, my name is Jarno!!!'
    ,
      title: 'Second Article'
      'title@href': "/articles/2"
      body: 'Hello World, my name is Sanna!!!'
    ,
      title: 'Third Article'
      'title@href': "/articles/3"
      body: 'Hello World, here we are!!!'
    ]

# Routes
app.get "/.:format?", (req, res) ->   
  if req.params.format == "json"
    res.send database.articles # Filter Article.body out in the real world
  else
    res.render "index"

app.get "/articles/:id.:format?", (req, res) ->
  if req.params.format == "json"
    res.send database.articles[req.params.id - 1]
  else
    res.render "index"

app.listen 3000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
