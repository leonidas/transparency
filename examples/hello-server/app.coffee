express      = require "express"
jsdom        = require("jsdom").jsdom
$            = require "jquery"
transparency = require "transparency"

# Register transparency as a plugin for the given jQuery instance
transparency.register $

app = express()

app.configure ->
  app.use app.router

app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

app.get "/", (req, res) ->

  data = [
    title: "Hello"
  ,
    title: "Howdy"
  ,
    title: "Cheers"
  ,
    title: "Byebye"
  ]

  ### templating with jsdom - uncomment to use
  doc = jsdom """
    <div id="templates">

      <!-- Items template -->
      <ul id="items">
        <li class="title"></li>
      </ul>

      <!-- Person template -->
      <div class="person">
        <div class="name"></div>
        <div class="email"></div>
      </div>

    </div>
    """

  template = doc.getElementById "items"
  result   = transparency.render template, data
  res.send template.outerHTML
  ###

  # templating with jQuery - remove if using jsdom
  template = $ """
    <ul id="items">
      <li class="title"></li>
    </ul>
    """
  result = template.render data
  res.send template[0].outerHTML

app.listen 3000
console.log "Express server listening on port 3000 in %s mode", app.settings.env
