## Introduction

Transparency is heavily influenced by PURE. Having the same spirit, it is even more opinionated about how the templates and data are bind together. Templating should be unobustrive, dead simple and just stay out of the way.

Transparency relies on convention over configuration and requires you to have 1:1 match between css classes and json objects. Usually this is a good idea anyway, and minimizes the amount of cognitive noise you have to deal with. 

Otherwise, there's nothing else you need to do. Just call $('my-template').render(data) and enjoy your life.

## Examples

### Hello World

Template:
```html
<div class="hello"><a class="world" href="#"></span>
</div>
```

Javascript:
```js
var greeting = {
  hello:        'Hello '
  world:        'World!!!'
  'world@href': 'www.example.com'
};

Result:
```html
<div class="hello">Hello <a class="world" href="www.example.com">World!!!</span>
</div>
```

### Iterate over a list (look ma', no hands!)

It's just like rendering a signle object

### The name?

Transparency refers to overhead transparencies. Yeah, those projectors and hand-made transparencies of the 80's! Can you feel the vintage? :)
