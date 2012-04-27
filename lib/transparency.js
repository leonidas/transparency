(function() {
  var ELEMENT_NODE, T, Transparency, cache, clone, elementMatcher, elementNodes, expando, matchingElements, prepareContext, renderChildren, renderDirectives, renderValues, setContent, setHtml, setText, uid, _base;

  if (typeof jQuery !== "undefined" && jQuery !== null) {
    jQuery.fn.render = function(models, directives) {
      T.render(this.get(), models, directives);
      return this;
    };
  }

  this.Transparency = Transparency = {};

  if (typeof module !== "undefined" && module !== null) {
    module.exports = Transparency;
  }

  T = Transparency;

  expando = "transparency-" + Math.random();

  uid = 0;

  cache = {};

  T.data = function(element) {
    var id, val, _ref;
    id = (_ref = element[expando]) != null ? _ref : element[expando] = uid++;
    return val = cache[id] || (cache[id] = {});
  };

  T.render = function(contexts, models, directives) {
    var c, context, contextData, e, index, instance, model, parent, sibling, _i, _j, _len, _len2, _len3, _ref;
    if (!contexts) return;
    models || (models = []);
    directives || (directives = {});
    contexts = (contexts.length != null) && contexts[0] ? (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = contexts.length; _i < _len; _i++) {
        c = contexts[_i];
        _results.push(c);
      }
      return _results;
    })() : [contexts];
    if (!Array.isArray(models)) models = [models];
    for (_i = 0, _len = contexts.length; _i < _len; _i++) {
      context = contexts[_i];
      sibling = context.nextSibling;
      parent = context.parentNode;
      if (parent != null) parent.removeChild(context);
      prepareContext(context, models);
      contextData = T.data(context);
      for (index = 0, _len2 = models.length; index < _len2; index++) {
        model = models[index];
        instance = contextData.instances[index];
        _ref = instance.elements;
        for (_j = 0, _len3 = _ref.length; _j < _len3; _j++) {
          e = _ref[_j];
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
    }
    return contexts;
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
    while (models.length > contextData.instances.length) {
      instance = contextData.instanceCache.pop() || {};
      instance.queryCache || (instance.queryCache = {});
      instance.template || (instance.template = (function() {
        var _i, _len, _ref, _results;
        _ref = contextData.template;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          n = _ref[_i];
          if ((n != null ? n.nodeType : void 0) === ELEMENT_NODE) {
            _results.push(clone(n));
          }
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
      if (!((e != null ? e.nodeType : void 0) === ELEMENT_NODE)) continue;
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
    return element.id === key || element.className.split(' ').indexOf(key) > -1 || element.name === key || element.getAttribute('data-bind') === key;
  };

  ELEMENT_NODE = 1;

  clone = document.createElement("nav").cloneNode(true).outerHTML !== "<:nav></:nav>" ? function(node) {
    return node.cloneNode(true);
  } : function(node) {
    var div, _ref;
    div = document.createElement("div");
    div.innerHTML = node.outerHTML;
    if ((_ref = div.firstChild) != null) _ref.removeAttribute(expando);
    return div.firstChild;
  };

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

  if (Array.isArray == null) {
    Array.isArray = function(ob) {
      return Object.prototype.toString.call(ob) === '[object Array]';
    };
  }

}).call(this);
