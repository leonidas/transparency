var AttributeFactory, Checkbox, Element, ElementFactory, Input, Radio, Select, TextArea, VoidElement, helpers, _,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

_ = require('../lib/lodash.js');

helpers = require('./helpers');

AttributeFactory = require('./attributeFactory');

module.exports = ElementFactory = {
  Elements: {
    input: {}
  },
  createElement: function(el) {
    var El, name;
    if ('input' === (name = el.nodeName.toLowerCase())) {
      El = ElementFactory.Elements[name][el.type.toLowerCase()] || Input;
    } else {
      El = ElementFactory.Elements[name] || Element;
    }
    return new El(el);
  }
};

Element = (function() {
  function Element(el) {
    this.el = el;
    this.attributes = {};
    this.childNodes = _.toArray(this.el.childNodes);
    this.nodeName = this.el.nodeName.toLowerCase();
    this.classNames = this.el.className.split(' ');
    this.originalAttributes = {};
  }

  Element.prototype.empty = function() {
    var child;
    while (child = this.el.firstChild) {
      this.el.removeChild(child);
    }
    return this;
  };

  Element.prototype.reset = function() {
    var attribute, name, _ref, _results;
    _ref = this.attributes;
    _results = [];
    for (name in _ref) {
      attribute = _ref[name];
      _results.push(attribute.set(attribute.templateValue));
    }
    return _results;
  };

  Element.prototype.render = function(value) {
    return this.attr('text', value);
  };

  Element.prototype.attr = function(name, value) {
    var attribute, _base;
    attribute = (_base = this.attributes)[name] || (_base[name] = AttributeFactory.createAttribute(this.el, name, value));
    if (value != null) {
      attribute.set(value);
    }
    return attribute;
  };

  Element.prototype.renderDirectives = function(model, index, attributes) {
    var directive, name, value, _results;
    _results = [];
    for (name in attributes) {
      if (!__hasProp.call(attributes, name)) continue;
      directive = attributes[name];
      if (!(typeof directive === 'function')) {
        continue;
      }
      value = directive.call(model, {
        element: this.el,
        index: index,
        value: this.attr(name).templateValue
      });
      if (value != null) {
        _results.push(this.attr(name, value));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  return Element;

})();

Select = (function(_super) {
  __extends(Select, _super);

  ElementFactory.Elements['select'] = Select;

  function Select(el) {
    Select.__super__.constructor.call(this, el);
    this.elements = helpers.getElements(el);
  }

  Select.prototype.render = function(value) {
    var option, _i, _len, _ref, _results;
    value = value.toString();
    _ref = this.elements;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      option = _ref[_i];
      if (option.nodeName === 'option') {
        _results.push(option.attr('selected', option.el.value === value));
      }
    }
    return _results;
  };

  return Select;

})(Element);

VoidElement = (function(_super) {
  var VOID_ELEMENTS, nodeName, _i, _len;

  __extends(VoidElement, _super);

  function VoidElement() {
    return VoidElement.__super__.constructor.apply(this, arguments);
  }

  VOID_ELEMENTS = ['area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'input', 'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr'];

  for (_i = 0, _len = VOID_ELEMENTS.length; _i < _len; _i++) {
    nodeName = VOID_ELEMENTS[_i];
    ElementFactory.Elements[nodeName] = VoidElement;
  }

  VoidElement.prototype.attr = function(name, value) {
    if (name !== 'text' && name !== 'html') {
      return VoidElement.__super__.attr.call(this, name, value);
    }
  };

  return VoidElement;

})(Element);

Input = (function(_super) {
  __extends(Input, _super);

  function Input() {
    return Input.__super__.constructor.apply(this, arguments);
  }

  Input.prototype.render = function(value) {
    return this.attr('value', value);
  };

  return Input;

})(VoidElement);

TextArea = (function(_super) {
  __extends(TextArea, _super);

  function TextArea() {
    return TextArea.__super__.constructor.apply(this, arguments);
  }

  ElementFactory.Elements['textarea'] = TextArea;

  return TextArea;

})(Input);

Checkbox = (function(_super) {
  __extends(Checkbox, _super);

  function Checkbox() {
    return Checkbox.__super__.constructor.apply(this, arguments);
  }

  ElementFactory.Elements['input']['checkbox'] = Checkbox;

  Checkbox.prototype.render = function(value) {
    return this.attr('checked', Boolean(value));
  };

  return Checkbox;

})(Input);

Radio = (function(_super) {
  __extends(Radio, _super);

  function Radio() {
    return Radio.__super__.constructor.apply(this, arguments);
  }

  ElementFactory.Elements['input']['radio'] = Radio;

  return Radio;

})(Checkbox);
