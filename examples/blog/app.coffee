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
  id: 0
  title: 'First Article'
  body: 'Hello World, this is my First article!!!'
,
  id: 1
  title: 'Second Article'
  body: 'Hello World, this is my Second article!!!'
,
  id: 2
  title: 'Third Article'
  body: 'Hello World, here we are!!!'
]

# Routes
app.get "/", (req, res) ->
    res.render "index"

app.get "/articles.:format?", (req, res) ->
  if req.params.format == "json"
    res.send database.articles
  else
    res.render "index"

app.get "/articles/:id.:format?", (req, res) ->
  if req.params.format == "json"
    res.send database.articles[req.params.id]
  else
    res.render "index"

app.post "/articles", (req, res) ->
  article    = req.body.article
  article.id = database.articles.length
  database.articles.push article
  res.send "/articles/#{article.id}"

app.listen 3000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
