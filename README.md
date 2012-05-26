# Synopsis

Transparency is a client-side template engine which binds data to DOM. Just call `.render(data)`.

```html
<div id="template">
  <span class="greeting"></span>
  <span data-bind="name"></span>
</div>
```

```js
var hello = {
  greeting: 'Hello',
  name:     'world!'
};

$('#template').render(hello);
```

```html
<div id="template">
  <span class="greeting">Hello</span>
  <span data-bind="name">world!</span>
</div>
```

[![Build Status](https://secure.travis-ci.org/leonidas/transparency.png?branch=master)](http://travis-ci.org/leonidas/transparency)

## Features

* **Semantic data binding** - No `<%=foo%>` or `{{foo}}` assignments polluting the HTML
* **Collection rendering** - No need for hand-written loops in the HTML
* **Valid HTML templates** - Write templates as a part of the HTML, in plain HTML. Use any HTML editor you like
* **Plain JavaScript logic** - All the power without learning yet another micro programming language
* **[Blazing fast](https://github.com/leonidas/transparency/wiki/Defining-template-engine-performance)** - Templates are cached and optimized automatically

Transparency is compatible with IE9+, Chrome, Firefox, iOS, Android and other mobile browsers. Support for older 
IE browsers requires jQuery.

## Fiddle

[Project home page](http://leonidas.github.com/transparency/) with interactive examples.

## Install

#### Browser

Get the [compiled and minified version](https://raw.github.com/leonidas/transparency/master/lib/transparency.min.js)
and include it to your application. jQuery is optional, but if you happen to use it, Transparency registers itself
as a plugin.

```html
<script src="js/jquery-1.7.1.min.js"></script>
<script src="js/transparency.min.js"></script>
```

#### AMD

```javascript
require(['jquery', 'transparency'], function($, transparency){
  // With jQuery
  $('#template').render(data);
  
  // Without jQuery
  transparency.render(document.getElementById('template'), data);
});
```

#### Node.js

`npm install transparency`

For server-side use, see 
[examples/hello-server](https://github.com/leonidas/transparency/tree/master/examples/hello-server).

## Use

[For more complex use case examples, see User manual](https://github.com/leonidas/transparency/wiki/User-Manual)

### Binding values

Transparency binds JavaScript objects to DOM a element by `id`, `class`,`name` attribute and
`data-bind` attribute. Values are escaped before rendering.

Template:

```html
<div id="container">
  <div id="hello"></div>
  <div class="goodbye"></div>
  <input type="text" name="greeting" />
  <button class="hi-button" data-bind="hi-label"></button>
</div>
```

Javascript:

```js
var hello = {
  hello:      'Hello',
  goodbye:    '<i>Goodbye!</i>',
  greeting:   'Howdy!',
  'hi-label': 'Terve!' // Finnish i18n
};

// with jQuery
$('#container').render(hello);

// ..or without
Transparency.render(document.getElementById('container'), hello);
```

Result:

```html
<div class="container">
  <div id="hello">Hello</div>
  <div class="goodbye">lt;i&gt;Goodbye!&lt;/i&gt;</div>
  <input type="text" name="greeting" value="Howdy!" />
  <button class="hi-button" data-bind="hi-label">Terve!</button>
</div>
```

### Rendering a list of models

Template:

```html
<ul id="activities">
  <li class="activity"></li>
</ul>
```

Javascript:

```js
var activities = [
  {activity: 'Jogging'},
  {activity: 'Gym'},
  {activity: 'Sky Diving'},
];

$('#activities').render(activities);

// or
Transparency.render(document.getElementById('activities'), activities);
```

Result:

```html
<ul id="activities">
  <li class="activity">Jogging</li>
  <li class="activity">Gym</li>
  <li class="activity">Sky Diving</li>
</ul>
```

#### Rendering a list of plain values

With plain values, Transparency can't guess how you would like to bind the data to DOM, so a bit of
help is needed. Directives are just for that.

Access to the plain values within the directives is provided through `this.value`. There's a whole
lot more to say about the directives, but that's all we need for now. For the details, see
section [Directives](https://github.com/leonidas/transparency#directives).

Template:

```html
<div>
  <div class="comments">
    <label>Comments:</label><span class="comment"></span>
  </div>
</div>
```

Javascript:

```js
var comments, directives;

comments = ["That rules", "Great post!"];

// See section 'Directives' for the details
directives = {
  comment: {
    text: function() {
      return this.value;
    }
  }
};

$('.comments').render(comments, directives);
```

Result:

```html
<div>
  <div class="comments">
    <label>Comments</label><span class="comment">That rules</span>
    <label>Comments</label><span class="comment">Great post!</span>
  </div>
</div>
```

### Nested lists

Template:

```html
<div class="container">
  <h1 class="title"></h1>
  <p class="post"></p>
  <div class="comments">
    <div class="comment">
      <span class="name"></span>
      <span class="text"></span>
    </div>
  </div>
</div>
```

Javascript:

```js
var post = {
  title:    'Hello World',
  post:     'Hi there it is me',
  comments: [ {
      name: 'John',
      text: 'That rules'
    }, {
      name: 'Arnold',
      text: 'Great post!'
    }
  ]
};

$('.container').render(post);
```

Result:

```html
<div class="container">
  <h1 class="title">Hello World</h1>
  <p class="post">Hi there it is me</p>
  <div class="comments">
    <div class="comment">
      <span class="name">John</span>
      <span class="text">That rules</span>
    </div>
    <div class="comment">
      <span class="name">Arnold</span>
      <span class="text">Great post!</span>
    </div>
  </div>
</div>
```

### Nested objects

Template:

```html
<div class="person">
  <div class="firstname"></div>
  <div class="lastname"></div>
  <div class="address">
    <div class="street"></div>
    <div class="zip"><span class="city"></span></div>
  </div>
</div>
```

Javascript:

```js
var person = {
  firstname: 'John',
  lastname:  'Wayne',
  address: {
    street: '4th Street',
    city:   'San Francisco',
    zip:    '94199'
  }
};

$('.person').render(person);
```

Result:

```html
<div class="container">
  <div class="firstname">John</div>
  <div class="lastname">Wayne</div>
  <div class="address">
    <div class="street">4th Street</div>
    <div class="zip">94199<span class="city">San Francisco</span></div>
  </div>
</div>
```

### Directives

Directives are actions Transparency performs while rendering the templates. They can be used for setting element
`text` or `html` content and attribute values, e.g., `class`, `src` or `href`.

Directives are plain javascript functions defined in a two-dimensional object literal, i.e.,

`directives[element][attribute] = function(params) {...}`

where `element` is value of `id`, `class`, `name` attribute or `data-bind` attribute of the target element. Similarly,
`attribute` is the name of the target attribute.

Directive functions receive current model as `this` paramater. In addition, they receive current element as
`params.element`, current index as `params.index` and current value as `params.value`.

The return value of a directive function is assigned to the matching element's attribute. The return value should be string.

Template:

```html
<div class="person">
  <span class="name"></span>
  <a class="email"></a>
</div>
```

Javascript:

```js
var person, directives;

person = {
  firstname: 'Jasmine',
  lastname:  'Taylor',
  email:     'jasmine.tailor@example.com'
};

directives = {
  name: {
    html: function(params) {
      return "<b>" + this.firstname + " " + this.lastname + "</b>";
    }
  },

  email: {
    href: function(params) {
      return this.email;
    }
  }
};

$('.person').render(person, directives);
```

Result:

```html
<div class="person">
  <span class="name"><b>Jasmine Taylor</b></span>
  <a class="email" href="mailto:jasmine.tailor@example.com">jasmine.tailor@example.com</a>
</div>
```

### Nested directives

Template:

```html
<div class="person">
  <span class="name"></span>
  <span class="email"></span>
  <div class="friends">
    <div class="friend">
      <span class="name"></span>
      <span class="email"></span>
    </div>
  </div>
</div>
```

Javascript:

```js
person = {
  firstname:  'Jasmine',
  lastname:   'Taylor',
  email:      'jasmine.taylor@example.com',
  friends:    [ {
      firstname: 'John',
      lastname:  'Mayer',
      email:     'john.mayer@example.com'
    }, {
      firstname: 'Damien',
      lastname:  'Rice',
      email:     'damien.rice@example.com'
    }
  ]
};

nameDecorator = function() { "<b>" + this.firstname + " " + this.lastname + "</b>"; };

directives = {
  name: { html: nameDecorator },

  friends: {
    name: { html: nameDecorator }
  }
};

$('.person').render(person, directives);
```

Result:

```html
<div class="person">
  <span class="name"><b>Jasmine Taylor</b></span>
  <span class="email">jasmine.taylor@example.com</span>
  <div class="friends">
    <div class="friend">
      <span class="name"><b>John Mayer</b></span>
      <span class="email">john.mayer@example.com</span>
    </div>
    <div class="friend">
      <span class="name"><b>Damien Rice</b></span>
      <span class="email">damien.rice@example.com</span>
    </div>
  </div>
</div>
```

## Debugging templates, data and Transparency

http://leonidas.github.com/transparency/ is great place to fiddle around with your data and templates.

To enable debug mode, call `.render` with a `{debug: true}` config and open the javascript console.

```javascript
$('container').render(data, {}, {debug: true});
```

## Getting help

* [FAQ](https://github.com/leonidas/transparency/wiki/Frequently-Asked-Questions)
* IRC: [freenode/#transparency.js](http://webchat.freenode.net/)
* Google Groups: transparencyjs@googlegroups.com

## Development environment

You need node.js 0.6.x and npm.

Install dependencies:

    npm install
    npm install -g uglify-js
    npm install -g coffee-script

Run tests

    npm test

Run tests during development for more verbose assertion output

    node_modules/jasmine-node/bin/jasmine-node --coffee --verbose spec

Generate Javascript libs

    cake build

Use [debugger statement to debug spec scripts](http://bytes.goodeggsinc.com/post/11587373922/debugging-jasmine-node-and-coffeescript-specs).

## Contributing

All the following are appreciated, in an asceding order of preference

1. A feature request or a bug report
2. Pull request with a failing unit test
3. Pull request with unit tests and corresponding implementation

In case the contribution is going to change Transparency API, please create a ticket first in order to discuss and
agree on design.

There's [an article](https://github.com/leonidas/codeblog/blob/master/2012/2012-01-13-implementing-semantic-anti-templating-with-jquery.md)
regarding the original design and implementation. It might be worth reading as an introduction.


