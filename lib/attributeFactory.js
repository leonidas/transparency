var Attribute, AttributeFactory, BooleanAttribute, Class, Html, Text, helpers, _,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

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
  function Attribute(el, name) {
    this.el = el;
    this.name = name;
    this.templateValue = this.el.getAttribute(this.name) || '';
  }

  Attribute.prototype.set = function(value) {
    this.el[this.name] = value;
    return this.el.setAttribute(this.name, value.toString());
  };

  return Attribute;

})();

BooleanAttribute = (function(_super) {
  var BOOLEAN_ATTRIBUTES, name, _i, _len;

  __extends(BooleanAttribute, _super);

  BOOLEAN_ATTRIBUTES = ['hidden', 'async', 'defer', 'autofocus', 'formnovalidate', 'disabled', 'autofocus', 'formnovalidate', 'multiple', 'readonly', 'required', 'checked', 'scoped', 'reversed', 'selected', 'loop', 'muted', 'autoplay', 'controls', 'seamless', 'default', 'ismap', 'novalidate', 'open', 'typemustmatch', 'truespeed'];

  for (_i = 0, _len = BOOLEAN_ATTRIBUTES.length; _i < _len; _i++) {
    name = BOOLEAN_ATTRIBUTES[_i];
    AttributeFactory.Attributes[name] = BooleanAttribute;
  }

  function BooleanAttribute(el, name) {
    this.el = el;
    this.name = name;
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

Text = (function(_super) {
  __extends(Text, _super);

  AttributeFactory.Attributes['text'] = Text;

  function Text(el, name) {
    var child;
    this.el = el;
    this.name = name;
    this.templateValue = ((function() {
      var _i, _len, _ref, _results;
      _ref = this.el.childNodes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        if (child.nodeType === helpers.TEXT_NODE) {
          _results.push(child.nodeValue);
        }
      }
      return _results;
    }).call(this)).join('');
    this.children = _.toArray(this.el.children);
    if (!(this.textNode = this.el.firstChild)) {
      this.el.appendChild(this.textNode = this.el.ownerDocument.createTextNode(''));
    } else if (this.textNode.nodeType !== helpers.TEXT_NODE) {
      this.textNode = this.el.insertBefore(this.el.ownerDocument.createTextNode(''), this.textNode);
    }
  }

  Text.prototype.set = function(text) {
    var child, _i, _len, _ref, _results;
    while (child = this.el.firstChild) {
      this.el.removeChild(child);
    }
    this.textNode.nodeValue = text;
    this.el.appendChild(this.textNode);
    _ref = this.children;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      child = _ref[_i];
      _results.push(this.el.appendChild(child));
    }
    return _results;
  };

  return Text;

})(Attribute);

Html = (function(_super) {
  __extends(Html, _super);

  AttributeFactory.Attributes['html'] = Html;

  function Html(el) {
    this.el = el;
    this.templateValue = '';
    this.children = _.toArray(this.el.children);
  }

  Html.prototype.set = function(html) {
    var child, _i, _len, _ref, _results;
    while (child = this.el.firstChild) {
      this.el.removeChild(child);
    }
    this.el.innerHTML = html + this.templateValue;
    _ref = this.children;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      child = _ref[_i];
      _results.push(this.el.appendChild(child));
    }
    return _results;
  };

  return Html;

})(Attribute);

Class = (function(_super) {
  __extends(Class, _super);

  AttributeFactory.Attributes['class'] = Class;

  function Class(el) {
    Class.__super__.constructor.call(this, el, 'class');
  }

  return Class;

})(Attribute);
