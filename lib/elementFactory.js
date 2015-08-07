var AttributeFactory, Checkbox, Element, ElementFactory, Input, Radio, Select, TextArea, VoidElement, _, helpers,
  hasProp = {}.hasOwnProperty,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

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
  function Element(el1) {
    this.el = el1;
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
    var attribute, name, ref, results;
    ref = this.attributes;
    results = [];
    for (name in ref) {
      attribute = ref[name];
      results.push(attribute.set(attribute.templateValue));
    }
    return results;
  };

  Element.prototype.render = function(value) {
    return this.attr('text', value);
  };

  Element.prototype.attr = function(name, value) {
    var attribute, base;
    attribute = (base = this.attributes)[name] || (base[name] = AttributeFactory.createAttribute(this.el, name, value));
    if (value != null) {
      attribute.set(value);
    }
    return attribute;
  };

  Element.prototype.renderDirectives = function(model, index, attributes) {
    var directive, name, results, value;
    results = [];
    for (name in attributes) {
      if (!hasProp.call(attributes, name)) continue;
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
        results.push(this.attr(name, value));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  return Element;

})();

Select = (function(superClass) {
  extend(Select, superClass);

  ElementFactory.Elements['select'] = Select;

  function Select(el) {
    Select.__super__.constructor.call(this, el);
    this.elements = helpers.getElements(el);
  }

  Select.prototype.render = function(value) {
    var i, len, option, ref, results;
    value = value.toString();
    ref = this.elements;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      option = ref[i];
      if (option.nodeName === 'option') {
        results.push(option.attr('selected', option.el.value === value));
      }
    }
    return results;
  };

  return Select;

})(Element);

VoidElement = (function(superClass) {
  var VOID_ELEMENTS, i, len, nodeName;

  extend(VoidElement, superClass);

  function VoidElement() {
    return VoidElement.__super__.constructor.apply(this, arguments);
  }

  VOID_ELEMENTS = ['area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'input', 'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr'];

  for (i = 0, len = VOID_ELEMENTS.length; i < len; i++) {
    nodeName = VOID_ELEMENTS[i];
    ElementFactory.Elements[nodeName] = VoidElement;
  }

  VoidElement.prototype.attr = function(name, value) {
    if (name !== 'text' && name !== 'html') {
      return VoidElement.__super__.attr.call(this, name, value);
    }
  };

  return VoidElement;

})(Element);

Input = (function(superClass) {
  extend(Input, superClass);

  function Input() {
    return Input.__super__.constructor.apply(this, arguments);
  }

  Input.prototype.render = function(value) {
    return this.attr('value', value);
  };

  return Input;

})(VoidElement);

TextArea = (function(superClass) {
  extend(TextArea, superClass);

  function TextArea() {
    return TextArea.__super__.constructor.apply(this, arguments);
  }

  ElementFactory.Elements['textarea'] = TextArea;

  return TextArea;

})(Input);

Checkbox = (function(superClass) {
  extend(Checkbox, superClass);

  function Checkbox() {
    return Checkbox.__super__.constructor.apply(this, arguments);
  }

  ElementFactory.Elements['input']['checkbox'] = Checkbox;

  Checkbox.prototype.render = function(value) {
    return this.attr('checked', Boolean(value));
  };

  return Checkbox;

})(Input);

Radio = (function(superClass) {
  extend(Radio, superClass);

  function Radio() {
    return Radio.__super__.constructor.apply(this, arguments);
  }

  ElementFactory.Elements['input']['radio'] = Radio;

  return Radio;

})(Checkbox);
