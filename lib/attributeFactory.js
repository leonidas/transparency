var Attribute, AttributeFactory, BooleanAttribute, Class, Html, Text, _, helpers,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_ = require('../lib/lodash');

helpers = require('./helpers');

module.exports = AttributeFactory = {
  Attributes: {},
  createAttribute: function(element, name) {
    var Attr;
    Attr = AttributeFactory.Attributes[name] || Attribute;
    return new Attr(element, name);
  }
};

Attribute = (function() {
  function Attribute(el1, name1) {
    this.el = el1;
    this.name = name1;
    this.templateValue = this.el.getAttribute(this.name) || '';
  }

  Attribute.prototype.set = function(value) {
    this.el[this.name] = value;
    return this.el.setAttribute(this.name, value.toString());
  };

  return Attribute;

})();

BooleanAttribute = (function(superClass) {
  var BOOLEAN_ATTRIBUTES, i, len, name;

  extend(BooleanAttribute, superClass);

  BOOLEAN_ATTRIBUTES = ['hidden', 'async', 'defer', 'autofocus', 'formnovalidate', 'disabled', 'autofocus', 'formnovalidate', 'multiple', 'readonly', 'required', 'checked', 'scoped', 'reversed', 'selected', 'loop', 'muted', 'autoplay', 'controls', 'seamless', 'default', 'ismap', 'novalidate', 'open', 'typemustmatch', 'truespeed'];

  for (i = 0, len = BOOLEAN_ATTRIBUTES.length; i < len; i++) {
    name = BOOLEAN_ATTRIBUTES[i];
    AttributeFactory.Attributes[name] = BooleanAttribute;
  }

  function BooleanAttribute(el1, name1) {
    this.el = el1;
    this.name = name1;
    this.templateValue = this.el.getAttribute(this.name) || false;
  }

  BooleanAttribute.prototype.set = function(value) {
    this.el[this.name] = value;
    if (value) {
      return this.el.setAttribute(this.name, this.name);
    } else {
      return this.el.removeAttribute(this.name);
    }
  };

  return BooleanAttribute;

})(Attribute);

Text = (function(superClass) {
  extend(Text, superClass);

  AttributeFactory.Attributes['text'] = Text;

  function Text(el1, name1) {
    var child;
    this.el = el1;
    this.name = name1;
    this.templateValue = ((function() {
      var i, len, ref, results;
      ref = this.el.childNodes;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        child = ref[i];
        if (child.nodeType === helpers.TEXT_NODE) {
          results.push(child.nodeValue);
        }
      }
      return results;
    }).call(this)).join('');
    this.children = _.toArray(this.el.children);
    if (!(this.textNode = this.el.firstChild)) {
      this.el.appendChild(this.textNode = this.el.ownerDocument.createTextNode(''));
    } else if (this.textNode.nodeType !== helpers.TEXT_NODE) {
      this.textNode = this.el.insertBefore(this.el.ownerDocument.createTextNode(''), this.textNode);
    }
  }

  Text.prototype.set = function(text) {
    var child, i, len, ref, results;
    while (child = this.el.firstChild) {
      this.el.removeChild(child);
    }
    this.textNode.nodeValue = text;
    this.el.appendChild(this.textNode);
    ref = this.children;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      child = ref[i];
      results.push(this.el.appendChild(child));
    }
    return results;
  };

  return Text;

})(Attribute);

Html = (function(superClass) {
  extend(Html, superClass);

  AttributeFactory.Attributes['html'] = Html;

  function Html(el1) {
    this.el = el1;
    this.templateValue = '';
    this.children = _.toArray(this.el.children);
  }

  Html.prototype.set = function(html) {
    var child, i, len, ref, results;
    while (child = this.el.firstChild) {
      this.el.removeChild(child);
    }
    this.el.innerHTML = html + this.templateValue;
    ref = this.children;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      child = ref[i];
      results.push(this.el.appendChild(child));
    }
    return results;
  };

  return Html;

})(Attribute);

Class = (function(superClass) {
  extend(Class, superClass);

  AttributeFactory.Attributes['class'] = Class;

  function Class(el) {
    Class.__super__.constructor.call(this, el, 'class');
  }

  return Class;

})(Attribute);
