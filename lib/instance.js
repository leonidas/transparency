var Instance, chainable, helpers, _,
  __hasProp = {}.hasOwnProperty;

_ = require('../lib/lodash.js');

chainable = (helpers = require('./helpers')).chainable;

module.exports = Instance = (function() {
  function Instance(template, Transparency) {
    this.Transparency = Transparency;
    this.queryCache = {};
    this.childNodes = _.toArray(template.childNodes);
    this.elements = helpers.getElements(template);
  }

  Instance.prototype.remove = chainable(function() {
    var node, _i, _len, _ref, _results;
    _ref = this.childNodes;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      node = _ref[_i];
      _results.push(node.parentNode.removeChild(node));
    }
    return _results;
  });

  Instance.prototype.appendTo = chainable(function(parent) {
    var node, _i, _len, _ref, _results;
    _ref = this.childNodes;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      node = _ref[_i];
      _results.push(parent.appendChild(node));
    }
    return _results;
  });

  Instance.prototype.prepare = chainable(function(model) {
    var element, _i, _len, _ref, _results;
    _ref = this.elements;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      element = _ref[_i];
      element.reset();
      _results.push(helpers.data(element.el).model = model);
    }
    return _results;
  });

  Instance.prototype.renderValues = chainable(function(model, children) {
    var element, key, value, _results;
    if (_.isElement(model) && (element = this.elements[0])) {
      return element.empty().el.appendChild(model);
    } else if (typeof model === 'object') {
      _results = [];
      for (key in model) {
        if (!__hasProp.call(model, key)) continue;
        value = model[key];
        if (value != null) {
          if (_.isString(value) || _.isNumber(value) || _.isBoolean(value) || _.isDate(value)) {
            _results.push((function() {
              var _i, _len, _ref, _results1;
              _ref = this.matchingElements(key);
              _results1 = [];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                element = _ref[_i];
                _results1.push(element.render(value));
              }
              return _results1;
            }).call(this));
          } else if (typeof value === 'object') {
            _results.push(children.push(key));
          } else {
            _results.push(void 0);
          }
        }
      }
      return _results;
    }
  });

  Instance.prototype.renderDirectives = chainable(function(model, index, directives) {
    var attributes, element, key, _results;
    _results = [];
    for (key in directives) {
      if (!__hasProp.call(directives, key)) continue;
      attributes = directives[key];
      if (!(typeof attributes === 'object')) {
        continue;
      }
      if (typeof model !== 'object') {
        model = {
          value: model
        };
      }
      _results.push((function() {
        var _i, _len, _ref, _results1;
        _ref = this.matchingElements(key);
        _results1 = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          element = _ref[_i];
          _results1.push(element.renderDirectives(model, index, attributes));
        }
        return _results1;
      }).call(this));
    }
    return _results;
  });

  Instance.prototype.renderChildren = chainable(function(model, children, directives, options) {
    var element, key, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = children.length; _i < _len; _i++) {
      key = children[_i];
      _results.push((function() {
        var _j, _len1, _ref, _results1;
        _ref = this.matchingElements(key);
        _results1 = [];
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          element = _ref[_j];
          _results1.push(this.Transparency.render(element.el, model[key], directives[key], options));
        }
        return _results1;
      }).call(this));
    }
    return _results;
  });

  Instance.prototype.matchingElements = function(key) {
    var el, elements, _base;
    elements = (_base = this.queryCache)[key] || (_base[key] = (function() {
      var _i, _len, _ref, _results;
      _ref = this.elements;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        el = _ref[_i];
        if (this.Transparency.matcher(el, key)) {
          _results.push(el);
        }
      }
      return _results;
    }).call(this));
    helpers.log("Matching elements for '" + key + "':", elements);
    return elements;
  };

  return Instance;

})();
