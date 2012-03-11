(function() {
  var ELEMENT_NODE, Transparency, elementMatcher, elementNodes, matchingElements, prepareContext, renderChildren, renderDirectives, renderValues, setContent, setHtml, setText, _base;

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

  Transparency.render = function(contexts, models, directives) {
    var c, context, e, index, instance, model, parent, sibling, _i, _j, _len, _len2, _len3, _ref;
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
    if (!(models instanceof Array)) models = [models];
    for (_i = 0, _len = contexts.length; _i < _len; _i++) {
      context = contexts[_i];
      sibling = context.nextSibling;
      parent = context.parentNode;
      if (parent != null) parent.removeChild(context);
      prepareContext(context, models);
      for (index = 0, _len2 = models.length; index < _len2; index++) {
        model = models[index];
        instance = context.transparency.instances[index];
        _ref = instance.elements;
        for (_j = 0, _len3 = _ref.length; _j < _len3; _j++) {
          e = _ref[_j];
          e.transparency.model = model;
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
    var attr, e, instance, n, template, value, _base, _base2, _base3, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3, _results;
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
    while (models.length < context.transparency.instances.length) {
      context.transparency.templateCache.push(instance = context.transparency.instances.pop());
      _ref2 = instance.template;
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        n = _ref2[_j];
        n.parentNode.removeChild(n);
      }
    }
    _ref3 = context.transparency.instances;
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
            _ref5 = e.transparency.attributes;
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
    var attr, directive, directiveFunction, element, key, value, _results;
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
              var _base, _base2, _results3;
              _results3 = [];
              for (attr in directive) {
                value = directive[attr];
                if (!(attr !== 'html' && attr !== 'text')) continue;
                (_base = element.transparency).attributes || (_base.attributes = {});
                (_base2 = element.transparency.attributes)[attr] || (_base2[attr] = element.getAttribute(attr));
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
            _results2.push(Transparency.render(element, value, directives[key]));
          }
          return _results2;
        })());
      }
    }
    return _results;
  };

  setContent = function(callback) {
    return function(e, content) {
      var c, n, _base, _i, _len, _ref, _results;
      if (!e || !(content != null) || e.transparency.content === content) return;
      e.transparency.content = content;
      (_base = e.transparency).children || (_base.children = (function() {
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
      _ref = e.transparency.children;
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
      if (!(e.nodeType === ELEMENT_NODE)) continue;
      e.transparency || (e.transparency = {});
      elements.push(e);
      _ref = e.getElementsByTagName('*');
      for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
        child = _ref[_j];
        child.transparency || (child.transparency = {});
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
