## Introduction

Transparency is heavily influenced by PURE. Having the same spirit, it is even more opinionated about how the templates and data are bind together. Templating should be unobustrive, dead simple and just stay out of the way.

Transparency relies on convention over configuration and requires you to have 1:1 match between css classes and json objects. Usually this is a good idea anyway, and minimizes the amount of cognitive noise you have to deal with. 

Otherwise, there's nothing else you need to do. Just call $('my-template').render(data) and enjoy your life.

## Examples

### Hello World

**Template:**

```html
<div class="container">
  <div class="greeting"><a class="name" href="#"></span>
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
<div class="container"
  <div class="greeting">Hello <a class="name" href="www.example.com">World!!!</span>
  </div>
</div>
```

### Iterate over a list (look ma', no hands!)

It's just like rendering a single object. No kidding, it's just the same.

**Template:**

```html
<div class="container">
  <div class="greeting"><a class="name" href="#"></span>
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
  <div class="greeting">Hello <a class="name" href="#">World!!!</span>
  </div>
  <div class="greeting">See you, <a class="name" href="#">Susan!</span>
  </div>
</div>
```

## The name?

Transparency refers to overhead projectors. Yeah, those projectors and hand-made transparencies of the 80's! Can you feel the vintage? :)
