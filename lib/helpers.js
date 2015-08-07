var ElementFactory, _getElements, expando, html5Clone;

ElementFactory = require('./elementFactory');

exports.before = function(decorator) {
  return function(method) {
    return function() {
      decorator.apply(this, arguments);
      return method.apply(this, arguments);
    };
  };
};

exports.after = function(decorator) {
  return function(method) {
    return function() {
      method.apply(this, arguments);
      return decorator.apply(this, arguments);
    };
  };
};

exports.chainable = exports.after(function() {
  return this;
});

exports.onlyWith$ = function(fn) {
  if ((typeof jQuery !== "undefined" && jQuery !== null) || (typeof Zepto !== "undefined" && Zepto !== null)) {
    return (function($) {
      return fn(arguments);
    })(jQuery || Zepto);
  }
};

exports.getElements = function(el) {
  var elements;
  elements = [];
  _getElements(el, elements);
  return elements;
};

_getElements = function(template, elements) {
  var child, results;
  child = template.firstChild;
  results = [];
  while (child) {
    if (child.nodeType === exports.ELEMENT_NODE) {
      elements.push(new ElementFactory.createElement(child));
      _getElements(child, elements);
    }
    results.push(child = child.nextSibling);
  }
  return results;
};

exports.ELEMENT_NODE = 1;

exports.TEXT_NODE = 3;

html5Clone = function() {
  return document.createElement('nav').cloneNode(true).outerHTML !== '<:nav></:nav>';
};

exports.cloneNode = (typeof document === "undefined" || document === null) || html5Clone() ? function(node) {
  return node.cloneNode(true);
} : function(node) {
  var cloned, element, i, len, ref;
  cloned = Transparency.clone(node);
  if (cloned.nodeType === exports.ELEMENT_NODE) {
    cloned.removeAttribute(expando);
    ref = cloned.getElementsByTagName('*');
    for (i = 0, len = ref.length; i < len; i++) {
      element = ref[i];
      element.removeAttribute(expando);
    }
  }
  return cloned;
};

expando = 'transparency';

exports.data = function(element) {
  return element[expando] || (element[expando] = {});
};

exports.nullLogger = function() {};

exports.consoleLogger = function() {
  return console.log(arguments);
};

exports.log = exports.nullLogger;
