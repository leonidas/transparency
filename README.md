Transparency is a minimal template engine for jQuery. It maps JSON objects to DOM elements with zero configuration.

## Features

* Data binding by convention - No extra markup in the views
* Collection rendering - No need for loops and partials
* Nested objects and lists - No configuration, just conventions
* Directives - No custom DSL, just functions

## Examples

Here's some of examples. For further details, please see the examples folder, tests and the source code.

### Assigning values and attributes (look ma', no assignment!)

Template:

```html
<div class="container">
  <div class="greeting"><a class="name" href="#"></a>
  </div>
</div>
```

Javascript:

```js
var hello = {
  greeting:     'Hello ',
  name:         'World!!!',
  'name@href':  'www.example.com'
};

$('.container').render(hello);
```

Result:

```html
<div class="container">
  <div class="greeting">Hello <a class="name" href="www.example.com">World!!!</a>
  </div>
</div>
```

**Note:** In order to avoid security hacks, e.g., setting `onclick` handlers for links, only following attributes can be set:
`id`, `class`, `src`, `alt`, `href` and `data-*`

### Iterating over a list (look ma', no loops!)

Template:

```html
<table >
  <thead>
    <tr>
      <th>Date</th>
      <th>Activity</th>
      <th>Comment</th>
      <th>Name</th>
    </tr>
  </head>
  <tbody class="activities">
    <tr class="activity">
      <td class="date"></td>
      <td class="activity"></td>
      <td class="comment"></td>
      <td class="name"></td>
    </tr>
  </tbody>
</table>
```

Javascript:

```js
var activities = [
  {
    date:     '2011-08-23',
    activity: 'Jogging',
    comment:  'Early morning run',
    name:     'Harry Potter'
  },
  {
    date:     '2011-09-04',
    activity: 'Gym',
    comment:  'Chest workout',
    name:     'Batman'
  }
];

$('.activities').render(activities);
```

Result:

```html
<table class="activities">
  <thead>
    <tr>
      <th>Date</th>
      <th>Activity</th>
      <th>Comment</th>
      <th>Name</th>
    </th>
  </thead>
  <tbody class="activities">
    <tr class="activity">
      <td class="date">2011-08-23</td>
      <td class="activity">Jogging</td>
      <td class="comment">Early morning run</td>
      <td class="name">Harry Potter</td>
    </tr>
    <tr class="activity">
      <td class="date">2011-09-04</td>
      <td class="activity">Gym</td>
      <td class="comment">Chest workout</td>
      <td class="name">Batman</td>
    </tr>
  </tbody>
</table>
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

Template:

```html
<div class="person">
  <span class="name"></span>
  <span class="email"></span>
</div>
```

Javascript:

```js
person = {
  firstname: 'Jasmine',
  lastname:  'Taylor',
  email:     'jasmine.tailor@example.com'
};

directives =
  name: function() {
    return "#{this.firstname} #{this.lastname}";
};

$('.person').render(person, directives);
```

Result:

```html
<div class="person">
  <span class="name">Jasmine Taylor</span>
  <span class="email">jasmine.tailor@example.com</span>
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
};

nameDecorator = function() { return this.firstname + " " + this.lastname };

directives = {
  name: nameDecorator,
  friends: {
    name: nameDecorator
  }
};

$('.person').render(person, directives);
```

Result:

```html
<div class="person">
  <span class="name">Jasmine Taylor</span>
  <span class="email">jasmine.taylor@example.com</span>
  <div class="friends">
    <div class="friend">
      <span class="name">John Mayer</span>
      <span class="email">john.mayer@example.com</span>
    </div>
    <div class="friend">
      <span class="name">Damien Rice</span>
      <span class="email">damien.rice@example.com</span>
    </div>
  </div>
</div>
```

## Philosophy

Transparency is heavily influenced by [PURE](http://beebole.com/pure/) but is even more opinionated about how 
templates and data bind together. Templating with Transparency is unobustrive, dead simple and just stays out of the way.

Transparency relies on convention over configuration and requires you to have 1:1 match between CSS classes and 
JSON objects. The idea is to minimize the cognitive noise you have to deal with. 
Just call `$('.container').render(data)` and move on.
