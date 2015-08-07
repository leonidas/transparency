var Instance, _, chainable, helpers,
  hasProp = {}.hasOwnProperty;

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
    var i, len, node, ref, results;
    ref = this.childNodes;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      node = ref[i];
      results.push(node.parentNode.removeChild(node));
    }
    return results;
  });

  Instance.prototype.appendTo = chainable(function(parent) {
    var i, len, node, ref, results;
    ref = this.childNodes;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      node = ref[i];
      results.push(parent.appendChild(node));
    }
    return results;
  });

  Instance.prototype.prepare = chainable(function(model) {
    var element, i, len, ref, results;
    ref = this.elements;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      element = ref[i];
      element.reset();
      results.push(helpers.data(element.el).model = model);
    }
    return results;
  });

  Instance.prototype.renderValues = chainable(function(model, children) {
    var element, key, results, value;
    if (_.isElement(model) && (element = this.elements[0])) {
      return element.empty().el.appendChild(model);
    } else if (typeof model === 'object') {
      results = [];
      for (key in model) {
        if (!hasProp.call(model, key)) continue;
        value = model[key];
        if (value != null) {
          if (_.isString(value) || _.isNumber(value) || _.isBoolean(value) || _.isDate(value)) {
            results.push((function() {
              var i, len, ref, results1;
              ref = this.matchingElements(key);
              results1 = [];
              for (i = 0, len = ref.length; i < len; i++) {
                element = ref[i];
                results1.push(element.render(value));
              }
              return results1;
            }).call(this));
          } else if (typeof value === 'object') {
            results.push(children.push(key));
          } else {
            results.push(void 0);
          }
        }
      }
      return results;
    }
  });

  Instance.prototype.renderDirectives = chainable(function(model, index, directives) {
    var attributes, element, key, results;
    results = [];
    for (key in directives) {
      if (!hasProp.call(directives, key)) continue;
      attributes = directives[key];
      if (!(typeof attributes === 'object')) {
        continue;
      }
      if (typeof model !== 'object') {
        model = {
          value: model
        };
      }
      results.push((function() {
        var i, len, ref, results1;
        ref = this.matchingElements(key);
        results1 = [];
        for (i = 0, len = ref.length; i < len; i++) {
          element = ref[i];
          results1.push(element.renderDirectives(model, index, attributes));
        }
        return results1;
      }).call(this));
    }
    return results;
  });

  Instance.prototype.renderChildren = chainable(function(model, children, directives, options) {
    var element, i, key, len, results;
    results = [];
    for (i = 0, len = children.length; i < len; i++) {
      key = children[i];
      results.push((function() {
        var j, len1, ref, results1;
        ref = this.matchingElements(key);
        results1 = [];
        for (j = 0, len1 = ref.length; j < len1; j++) {
          element = ref[j];
          results1.push(this.Transparency.render(element.el, model[key], directives[key], options));
        }
        return results1;
      }).call(this));
    }
    return results;
  });

  Instance.prototype.matchingElements = function(key) {
    var base, el, elements;
    elements = (base = this.queryCache)[key] || (base[key] = (function() {
      var i, len, ref, results;
      ref = this.elements;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        el = ref[i];
        if (this.Transparency.matcher(el, key)) {
          results.push(el);
        }
      }
      return results;
    }).call(this));
    helpers.log("Matching elements for '" + key + "':", elements);
    return elements;
  };

  return Instance;

})();
