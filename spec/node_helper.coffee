jsdom  = require('jsdom/lib/jsdom').jsdom
jQuery = require('jquery')

html = """
<!DOCTYPE html>
<html>
  <head>
  </head>
  <body>
    <div id='transparency'>
    </div>
  </body>
</html>"
"""


global.document     = jsdom(html)
global.window       = document.createWindow()
global.jQuery = global.$   = jQuery.create window
global.Transparency = require '../src/transparency'
