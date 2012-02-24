# Frequently Asked Questions

Here we have collected things which you might ponder to see whether Transparency would be a good solution for you. 

## Why DOM based templating

There are several strong arguments for using solutions like Transparency

* HTML based applications already operate on DOM trees

* Javascript is fine language for scripting, there is no need to invent new micro language for controlling the template logic

* Operating on DOM is fast

* Transparency templates validate thru HTML5 validator as the mark-up is not polluted with custom tags or directives

* Clean and more readable code if you do not need to mix programming language tags inside HTML  

* Web developers are familiar with DOM operations

Some more discussion

* [Micro Templates Are Dead](http://blog.nodejitsu.com/micro-templates-are-dead)

## What to do if my data does not match my templates

You might have several data models in your application, e.g.

* Storage model: how data is presented on the server, application logic, etc.

* Template model: how data is presented in the templates

If your storage model, i.e. data coming from your server, does not directly match the template code you need to re-map it. Many templating solutions do this in the template language itself. With Transparency you can

* Preprocess (storage) data model and convert it to template model before feeding it to `Transparency.render()` in your Javascript code.
  This is a simple operation of reading in a Javascript object and producing a new object out of it.

* Use Transparency directives to hint mapping data to DOM trees and generate template data in directive functions

## Other Transparency like solutions

* [Distal](http://code.google.com/p/distal/)

* [KnockoutJS](http://knockoutjs.com/)

* [PURE](http://beebole.com/pure/documentation/)

* [Plates](https://github.com/flatiron/plates)

## How do I create attributes with Transparency?

With directives.

HTML:

```html
<div class=linkz0r>
 	<a data-bind=link>
 		<h2 data-bind=name></h2>
 		<p class=description></p>
 	</a>  
</div>
```

Javascript:
```javascript
// Example of settings a link href attributes
$(document).ready(function() {

    data = {
      link : "http://opensourcehacker.com",
      name : "Open Source Hacker",
      description : "Cool dude writing about OSS development and stuff"
    };

    directives = {
      "link" : function(elem) { 
          // Set href attribute
          $(elem).attr("href", this.link);
          // This node does not have text payload 
          return ""; 
      }
    };

    $("#linkz0r").render(data, directives);
});
```

Output:
```html
<div id="linkz0r">
  <a data-bind="link" href="http://opensourcehacker.com">
  	<h2 data-bind="name">Open Source Hacker</h2>
  	<p class="description">Cool dude writing about OSS development and stuff</p></a>  
</div>
```

Alternative example. Note that you do not wish to have a directive and a data declaration
with the same name, or the contents of e.g. `<img>` tag will be populated with data text.

HTML:
```html
<div id=linkz0r-part-ii>
  <a data-bind=link>
      <img data-bind=img>
  </a>
</div>
```

Javascript:
```javascript
// Alternative example using @ directives
$(document).ready(function() {

    var myLink = "http://opensourcehacker.com";
    var myImg = "/logo.png";

    directives = {
      "link@href" : function() { return myLink; },
      "img@src" : function() { return myImg; }
    };

    $("#linkz0r-part-ii").render({}, directives);
});        
```

Output:
```html
<div id="linkz0r-part-ii">
  <a data-bind="link" href="http://opensourcehacker.com">
      <img data-bind="img" src="/logo.png">
  </a>
</div>
```

