(function() {
  var ELEMENT_NODE, Transparency, elementMatcher, elementNodes, matchingElements, prepareContext, renderChildren, renderDirectives, renderValues, setText, _base;

  if (typeof jQuery !== "undefined" && jQuery !== null) {
    jQuery.fn.render = function(models, directives) {
      Transparency.render(this.get(), models, directives);
      return this;
    };
  }

  this.Transparency = Transparency = {};

  if (typeof module !== "undefined" && module !== null) {
    module.exports = Transparency;
  }

  Transparency.safeHtml = function(str) {
    return {
      html: str,
      safeHtml: true
    };
  };

  Transparency.render = function(contexts, models, directives) {
    var c, context, e, i, instance, model, parent, sibling, _i, _j, _len, _len2, _len3, _ref;
    contexts = (contexts.length != null) && contexts[0] ? (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = contexts.length; _i < _len; _i++) {
        c = contexts[_i];
        _results.push(c);
      }
      return _results;
    })() : [contexts];
    if (!(models instanceof Array)) models = [models];
    directives || (directives = {});
    for (_i = 0, _len = contexts.length; _i < _len; _i++) {
      context = contexts[_i];
      sibling = context.nextSibling;
      parent = context.parentNode;
      if (parent != null) parent.removeChild(context);
      prepareContext(context, models);
      for (i = 0, _len2 = models.length; i < _len2; i++) {
        model = models[i];
        instance = context.transparency.instances[i];
        _ref = instance.elements;
        for (_j = 0, _len3 = _ref.length; _j < _len3; _j++) {
          e = _ref[_j];
          e.transparency || (e.transparency = {});
          e.transparency.model = model;
        }
        renderValues(instance, model);
        renderDirectives(instance, model, directives);
        renderChildren(instance, model, directives, context);
      }
      if (sibling) {
        if (parent != null) parent.insertBefore(context, sibling);
      } else {
        if (parent != null) parent.appendChild(context);
      }
    }
    return contexts;
  };

  prepareContext = function(context, models) {
    var instance, n, template, _base, _base2, _base3, _i, _len, _ref, _results;
    context.transparency || (context.transparency = {});
    (_base = context.transparency).template || (_base.template = ((function() {
      var _results;
      _results = [];
      while (context.firstChild) {
        _results.push(context.removeChild(context.firstChild));
      }
      return _results;
    })()));
    (_base2 = context.transparency).templateCache || (_base2.templateCache = []);
    (_base3 = context.transparency).instances || (_base3.instances = []);
    while (models.length > context.transparency.instances.length) {
      instance = context.transparency.templateCache.pop() || {
        queryCache: {},
        template: (template = (function() {
          var _i, _len, _ref, _results;
          _ref = context.transparency.template;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            n = _ref[_i];
            _results.push(n.cloneNode(true));
          }
          return _results;
        })()),
        elements: elementNodes(template)
      };
      _ref = instance.template;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        n = _ref[_i];
        context.appendChild(n);
      }
      context.transparency.instances.push(instance);
    }
    _results = [];
    while (models.length < context.transparency.instances.length) {
      context.transparency.templateCache.push(instance = context.transparency.instances.pop());
      _results.push((function() {
        var _j, _len2, _ref2, _results2;
        _ref2 = instance.template;
        _results2 = [];
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          n = _ref2[_j];
          _results2.push(n.parentNode.removeChild(n));
        }
        return _results2;
      })());
    }
    return _results;
  };

  renderValues = function(instance, model) {
    var element, key, value, _results;
    if (typeof model === 'object') {
      _results = [];
      for (key in model) {
        value = model[key];
        if (typeof value !== 'object' && typeof value !== 'function') {
          _results.push((function() {
            var _i, _len, _ref, _results2;
            _ref = matchingElements(instance, key);
            _results2 = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              element = _ref[_i];
              _results2.push(setText(element, value));
            }
            return _results2;
          })());
        }
      }
      return _results;
    } else {
      element = matchingElements(instance, 'listElement')[0] || instance.elements[0];
      if (element) return setText(element, model);
    }
  };

  renderDirectives = function(instance, model, directives) {
    var attr, directive, e, key, result, _ref, _results;
    _results = [];
    for (key in directives) {
      directive = directives[key];
      if (!(typeof directive === 'function')) continue;
      _ref = key.split('@'), key = _ref[0], attr = _ref[1];
      _results.push((function() {
        var _i, _len, _ref2, _results2;
        _ref2 = matchingElements(instance, key);
        _results2 = [];
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          e = _ref2[_i];
          result = directive.call(model, e);
          if (attr) {
            _results2.push(e.setAttribute(attr, result));
          } else {
            _results2.push(setText(e, result));
          }
        }
        return _results2;
      })());
    }
    return _results;
  };

  renderChildren = function(instance, model, directives, context) {
    var element, key, value, _results;
    _results = [];
    for (key in model) {
      value = model[key];
      if (typeof value === 'object') {
        _results.push((function() {
          var _i, _len, _ref, _results2;
          _ref = matchingElements(instance, key);
          _results2 = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            element = _ref[_i];
            _results2.push(Transparency.render(element, value, directives[key]));
          }
          return _results2;
        })());
      }
    }
    return _results;
  };

  setText = function(e, text) {
    var c, children, n, _i, _len, _ref, _results;
    if ((e != null ? (_ref = e.transparency) != null ? _ref.text : void 0 : void 0) === text) {
      return;
    }
    e.transparency || (e.transparency = {});
    e.transparency.text = text;
    children = (function() {
      var _i, _len, _ref2, _results;
      _ref2 = e.childNodes;
      _results = [];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        n = _ref2[_i];
        if (n.nodeType === ELEMENT_NODE) _results.push(n);
      }
      return _results;
    })();
    while (e.firstChild) {
      e.removeChild(e.firstChild);
    }
    if (e.nodeName.toLowerCase() === 'input') {
      e.setAttribute('value', text);
    } else if (text.safeHtml) {
      e.innerHTML = text.html;
    } else {
      e.appendChild(e.ownerDocument.createTextNode(text));
    }
    _results = [];
    for (_i = 0, _len = children.length; _i < _len; _i++) {
      c = children[_i];
      _results.push(e.appendChild(c));
    }
    return _results;
  };

  matchingElements = function(instance, key) {
    var e, _base;
    return (_base = instance.queryCache)[key] || (_base[key] = (function() {
      var _i, _len, _ref, _results;
      _ref = instance.elements;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        e = _ref[_i];
        if (elementMatcher(e, key)) _results.push(e);
      }
      return _results;
    })());
  };

  elementNodes = function(template) {
    var child, e, elements, _i, _j, _len, _len2, _ref;
    elements = [];
    for (_i = 0, _len = template.length; _i < _len; _i++) {
      e = template[_i];
      if (!(e.nodeType === ELEMENT_NODE)) continue;
      elements.push(e);
      _ref = e.getElementsByTagName('*');
      for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
        child = _ref[_j];
        elements.push(child);
      }
    }
    return elements;
  };

  elementMatcher = function(element, key) {
    return element.id === key || element.className.split(' ').indexOf(key) > -1 || element.name === key || element.nodeName.toLowerCase() === key.toLowerCase() || element.getAttribute('data-bind') === key;
  };

  ELEMENT_NODE = 1;

  if ((_base = Array.prototype).indexOf == null) {
    _base.indexOf = function(s) {
      var i, index, x, _len;
      index = -1;
      for (i = 0, _len = this.length; i < _len; i++) {
        x = this[i];
        if (!(x === s)) continue;
        index = i;
        break;
      }
      return index;
    };
  }

}).call(this);
