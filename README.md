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
var greeting = {
  greeting:     'Hello ',
  name:         'World!!!',
  'name@href':  'www.example.com'
};

$('.greeting').render(greeting);
```

**Result:**

```html
<div class="container">
  <div class="greeting">Hello <a class="name" href="www.example.com">World!!!</a>
  </div>
</div>
```

### Iterating over a list (look ma', no hands!)

It's just like rendering a single object. No kidding, it's just the same.

**Template:**

```html
<div class="container">
  <div class="greeting"><a class="name" href="#"></a>
  </div>
</div>
```

**Javascript:**

```js
var greetings = [
  {
    greeting:    'Hello ',
    name:        'World!!!',
    'name@href': 'www.example.com'
  },
  {
    greeting:    'See you, ',
    name:        'Susan!',
    'name@href': 'www.example.com'
  }
];

$('.greeting').render(greetings);
```

**Result:**

```html
<div class="container">
  <div class="greeting">Hello <a class="name" href="www.example.com">World!!!</a>
  </div>
  <div class="greeting">See you, <a class="name" href="www.example.com">Susan!</a>
  </div>
</div>
```

## Philosophy

Transparency is heavily influenced by [PURE](http://beebole.com/pure/) but is even more opinionated about how templates and data bind together. Templating with Transparency is unobustrive, dead simple and just stays out of the way.

Transparency relies on convention over configuration and requires you to have 1:1 match between CSS classes and JSON objects. The idea is to minimize the cognitive noise you have to deal with. Just call `$('.my-template').render(data)` and enjoy your life.

The name Transparency refers to overhead projectors. Yeah, those projectors and hand-made transparencies of the 80's! Can you feel the vintage? :)
