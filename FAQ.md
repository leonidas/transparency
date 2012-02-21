# Frequently Asked Questions

Here we have collected things which you might ponder to see whether Transparency would be a good solution for you. 

## Why DOM based templating

There are several strong arguments for using solutions like Transparency

* HTML based applications already operate on DOM trees

* Javascript is fine language for scripting, there is no need to invent new micro language for controlling the template logic

* Operating on DOM is fast

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

* [KnockoutJS](http://knockoutjs.com/)

* [PURE](http://beebole.com/pure/documentation/)

* [Plates](https://github.com/flatiron/plates)

