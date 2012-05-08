(function() {
  var ELEMENT_NODE, T, Transparency, cloneNode, debug, debugMode, elementMatcher, elementNodes, expando, matchingElements, prepareContext, renderChildren, renderDirectives, renderValues, setContent, setHtml, setText, _base,
    __slice = Array.prototype.slice;

  if (typeof jQuery !== "undefined" && jQuery !== null) {
    jQuery.fn.render = function(models, directives, config) {
      var t, _i, _len;
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        t = this[_i];
        T.render(t, models, directives, config);
      }
      return this;
    };
  }

  this.Transparency = Transparency = {};

  if (typeof module !== "undefined" && module !== null) {
    module.exports = Transparency;
  }

  T = Transparency;

  expando = 'transparency';

  T.data = function(element) {
    return element[expando] || (element[expando] = {});
  };

  debug = null;

  debugMode = function(debug) {
    if (debug && (typeof console !== "undefined" && console !== null)) {
      return function() {
        var m, messages, _i, _len, _results;
        messages = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        _results = [];
        for (_i = 0, _len = messages.length; _i < _len; _i++) {
          m = messages[_i];
          _results.push(console.log(m));
        }
        return _results;
      };
    } else {
      return function() {};
    }
  };

  T.render = function(context, models, directives, config) {
    var contextData, e, index, instance, model, parent, sibling, _i, _len, _len2, _ref;
    debug = debugMode(config != null ? config.debug : void 0);
    debug("Context", context, "Models", models, "Directives", directives, "Config", config);
    if (!context) return;
    models || (models = []);
    directives || (directives = {});
    if (!Array.isArray(models)) models = [models];
    sibling = context.nextSibling;
    parent = context.parentNode;
    if (parent != null) parent.removeChild(context);
    prepareContext(context, models);
    contextData = T.data(context);
    for (index = 0, _len = models.length; index < _len; index++) {
      model = models[index];
      instance = contextData.instances[index];
      debug("Model", model, "Template instance", instance);
      _ref = instance.elements;
      for (_i = 0, _len2 = _ref.length; _i < _len2; _i++) {
        e = _ref[_i];
        T.data(e).model = model;
      }
      renderValues(instance, model);
      renderDirectives(instance, model, directives, index);
      renderChildren(instance, model, directives);
    }
    if (sibling) {
      if (parent != null) parent.insertBefore(context, sibling);
    } else {
      if (parent != null) parent.appendChild(context);
    }
    return context;
  };

  prepareContext = function(context, models) {
    var attr, contextData, e, instance, n, value, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3, _results;
    contextData = T.data(context);
    contextData.template || (contextData.template = ((function() {
      var _results;
      _results = [];
      while (context.firstChild) {
        _results.push(context.removeChild(context.firstChild));
      }
      return _results;
    })()));
    contextData.instanceCache || (contextData.instanceCache = []);
    contextData.instances || (contextData.instances = []);
    debug("Template", contextData.template);
    while (models.length > contextData.instances.length) {
      instance = contextData.instanceCache.pop() || {};
      instance.queryCache || (instance.queryCache = {});
      instance.template || (instance.template = (function() {
        var _i, _len, _ref, _results;
        _ref = contextData.template;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          n = _ref[_i];
          if (n.nodeType === ELEMENT_NODE) _results.push(cloneNode(n));
        }
        return _results;
      })());
      instance.elements || (instance.elements = elementNodes(instance.template));
      _ref = instance.template;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        n = _ref[_i];
        context.appendChild(n);
      }
      contextData.instances.push(instance);
    }
    while (models.length < contextData.instances.length) {
      contextData.instanceCache.push(instance = contextData.instances.pop());
      _ref2 = instance.template;
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        n = _ref2[_j];
        n.parentNode.removeChild(n);
      }
    }
    _ref3 = contextData.instances;
    _results = [];
    for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
      instance = _ref3[_k];
      _results.push((function() {
        var _l, _len4, _ref4, _results2;
        _ref4 = instance.elements;
        _results2 = [];
        for (_l = 0, _len4 = _ref4.length; _l < _len4; _l++) {
          e = _ref4[_l];
          _results2.push((function() {
            var _ref5, _results3;
            _ref5 = T.data(e).attributes;
            _results3 = [];
            for (attr in _ref5) {
              value = _ref5[attr];
              _results3.push(e.setAttribute(attr, value));
            }
            return _results3;
          })());
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

  renderDirectives = function(instance, model, directives, index) {
    var attr, directive, directiveFunction, element, elementData, key, value, _results;
    _results = [];
    for (key in directives) {
      directiveFunction = directives[key];
      if (typeof directiveFunction === 'function') {
        _results.push((function() {
          var _i, _len, _ref, _results2;
          _ref = matchingElements(instance, key);
          _results2 = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            element = _ref[_i];
            directive = directiveFunction.call(model, element, index);
            if (!directive) continue;
            if (typeof directive === 'string') {
              directive = {
                text: directive
              };
            }
            setText(element, directive.text);
            setHtml(element, directive.html);
            _results2.push((function() {
              var _base, _results3;
              _results3 = [];
              for (attr in directive) {
                value = directive[attr];
                if (!(attr !== 'html' && attr !== 'text')) continue;
                elementData = T.data(element);
                elementData.attributes || (elementData.attributes = {});
                (_base = elementData.attributes)[attr] || (_base[attr] = element.getAttribute(attr));
                _results3.push(element.setAttribute(attr, value));
              }
              return _results3;
            })());
          }
          return _results2;
        })());
      }
    }
    return _results;
  };

  renderChildren = function(instance, model, directives) {
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
            _results2.push(T.render(element, value, directives[key]));
          }
          return _results2;
        })());
      }
    }
    return _results;
  };

  setContent = function(callback) {
    return function(e, content) {
      var c, eData, n, _i, _len, _ref, _results;
      eData = T.data(e);
      if (!e || !(content != null) || eData.content === content) return;
      eData.content = content;
      eData.children || (eData.children = (function() {
        var _i, _len, _ref, _results;
        _ref = e.childNodes;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          n = _ref[_i];
          if (n.nodeType === ELEMENT_NODE) _results.push(n);
        }
        return _results;
      })());
      while (e.firstChild) {
        e.removeChild(e.firstChild);
      }
      callback(e, content);
      _ref = eData.children;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        c = _ref[_i];
        _results.push(e.appendChild(c));
      }
      return _results;
    };
  };

  setHtml = setContent(function(e, html) {
    return e.innerHTML = html;
  });

  setText = setContent(function(e, text) {
    if (e.nodeName.toLowerCase() === 'input') {
      return e.setAttribute('value', text);
    } else {
      return e.appendChild(e.ownerDocument.createTextNode(text));
    }
  });

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

  matchingElements = function(instance, key) {
    var e, elements, _base;
    elements = (_base = instance.queryCache)[key] || (_base[key] = (function() {
      var _i, _len, _ref, _results;
      _ref = instance.elements;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        e = _ref[_i];
        if (elementMatcher(e, key)) _results.push(e);
      }
      return _results;
    })());
    debug("Matching elements for '" + key + "'", elements);
    return elements;
  };

  elementMatcher = function(element, key) {
    return element.id === key || element.className.split(' ').indexOf(key) > -1 || element.name === key || element.getAttribute('data-bind') === key;
  };

  ELEMENT_NODE = 1;

  cloneNode = document.createElement("nav").cloneNode(true).outerHTML !== "<:nav></:nav>" ? function(node) {
    return node.cloneNode(true);
  } : function(node) {
    var div;
    div = document.createElement("div");
    div.innerHTML = node.outerHTML;
    div.firstChild.removeAttribute(expando);
    return div.firstChild;
  };

  if ((_base = Array.prototype).indexOf == null) {
    _base.indexOf = function(obj) {
      var i, index, x, _len;
      index = -1;
      for (i = 0, _len = this.length; i < _len; i++) {
        x = this[i];
        if (!(x === obj)) continue;
        index = i;
        break;
      }
      return index;
    };
  }

  if (Array.isArray == null) {
    Array.isArray = function(obj) {
      return Object.prototype.toString.call(obj) === '[object Array]';
    };
  }

}).call(this);
