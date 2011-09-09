Transparency is a minimal template engine for jQuery. It maps JSON objects to HTML values and attributes with zero configuration.

## Examples

**Template:**

```html
<div class="container">
  <div class="greeting"><a class="name" href="#"></a>
  </div>
</div>
```

**Javascript:**

```js
var hello = {
  greeting:     'Hello ',
  name:         'World!!!',
  'name@href':  'www.example.com'
};

$('.container').render(hello);
```

**Result:**

```html
<div class="container">
  <div class="greeting">Hello <a class="name" href="www.example.com">World!!!</a>
  </div>
</div>
```

### Iterating over a list (look ma', no hands!)

It's just like rendering a single object, which makes it easy to render, e.g., tables.

**Template:**

```html
<table class="activities">
  <tr>
    <th>Date</th>
    <th>Activity</th>
    <th>Comment</th>
    <th>Name</th>
  </th>
  <tr class="activity">
    <td class="date"></td>
    <td class="activity"></td>
    <td class="comment"></td>
    <td class="name"></td>
  </tr>
</table>
```

**Javascript:**

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

$('.activity').render(activities);
```

**Result:**

```html
<table class="activities">
  <tr>
    <th>Date</th>
    <th>Activity</th>
    <th>Comment</th>
    <th>Name</th>
  </th>
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
</table>
```

### Nested lists

**Template:**

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

**Javascript:**

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

**Result:**

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

**Template:**

```html
<div class="container">
  <div class="firstname"></div>
  <div class="lastname"></div>
  <div class="address">
    <div class="street"></div>
    <div class="zip"><span class="city"></span></div>
  </div>
</div>
```

**Javascript:**

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

$('.container').render(person);
```

**Result:**

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

## Philosophy

Transparency is heavily influenced by [PURE](http://beebole.com/pure/) but is even more opinionated about how templates and data bind together. Templating with Transparency is unobustrive, dead simple and just stays out of the way.

Transparency relies on convention over configuration and requires you to have 1:1 match between CSS classes and JSON objects. The idea is to minimize the cognitive noise you have to deal with. Just call `$('.my-template').render(data)` and enjoy your life.

The name Transparency refers to overhead projectors. Yeah, those projectors and hand-made transparencies of the 80's! Can you feel the vintage? :)
