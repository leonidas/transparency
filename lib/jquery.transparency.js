(function() {
  var TEXT_NODE, Transparency, elementMatcher, matchingElements, prepareContext, renderChildren, renderDirectives, renderValues, setValue;

  jQuery.fn.render = function(objects, directives) {
    Transparency.render(this.get(), objects, directives);
    return this;
  };

  Transparency = this.Transparency = {};

  Transparency.render = function(contexts, objects, directives) {
    var context, fragment, i, n, object, parent, sibling, _i, _j, _len, _len2, _len3, _ref;
    contexts = contexts.length != null ? Array.prototype.slice.call(contexts, 0) : [contexts];
    if (!(objects instanceof Array)) objects = [objects];
    directives || (directives = {});
    for (_i = 0, _len = contexts.length; _i < _len; _i++) {
      context = contexts[_i];
      sibling = context.nextSibling;
      parent = context.parentNode;
      if (parent != null) parent.removeChild(context);
      prepareContext(context, objects);
      fragment = context.ownerDocument.createDocumentFragment();
      for (i = 0, _len2 = objects.length; i < _len2; i++) {
        object = objects[i];
        _ref = context.transparency.instances[i];
        for (_j = 0, _len3 = _ref.length; _j < _len3; _j++) {
          n = _ref[_j];
          fragment.appendChild(n);
        }
        renderValues(fragment, object);
        renderDirectives(fragment, object, directives);
        renderChildren(fragment, object, directives);
        context.appendChild(fragment);
      }
      if (sibling) {
        if (parent != null) parent.insertBefore(context, sibling);
      } else {
        if (parent != null) parent.appendChild(context);
      }
    }
    return contexts;
  };

  prepareContext = function(context, objects) {
    var n, template, _base, _base2, _base3, _results;
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
    while (objects.length > context.transparency.instances.length) {
      template = context.transparency.templateCache.pop() || (map((function(n) {
        return n.cloneNode(true);
      }), context.transparency.template));
      context.transparency.instances.push(template);
    }
    _results = [];
    while (objects.length < context.transparency.instances.length) {
      _results.push(context.transparency.templateCache.push((function() {
        var _i, _len, _ref, _results2;
        _ref = context.transparency.instances.pop();
        _results2 = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          n = _ref[_i];
          _results2.push(context.removeChild(n));
        }
        return _results2;
      })()));
    }
    return _results;
  };

  renderValues = function(template, object) {
    var e, k, v, _results;
    if (typeof object === 'object') {
      _results = [];
      for (k in object) {
        v = object[k];
        if (typeof v !== 'object') {
          _results.push((function() {
            var _i, _len, _ref, _results2;
            _ref = matchingElements(template, k);
            _results2 = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              e = _ref[_i];
              _results2.push(setValue(e, v));
            }
            return _results2;
          })());
        }
      }
      return _results;
    } else {
      return setValue(matchingElements(template, 'listElement')[0] || template.getElementsByTagName('*')[0], object);
    }
  };

  renderDirectives = function(template, object, directives) {
    var attribute, directive, key, node, _ref, _results;
    _results = [];
    for (key in directives) {
      directive = directives[key];
      if (!(typeof directive === 'function')) continue;
      _ref = key.split('@'), key = _ref[0], attribute = _ref[1];
      _results.push((function() {
        var _i, _len, _ref2, _results2;
        _ref2 = matchingElements(template, key);
        _results2 = [];
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          node = _ref2[_i];
          _results2.push(setValue(node, directive.call(object, node), attribute));
        }
        return _results2;
      })());
    }
    return _results;
  };

  renderChildren = function(template, object, directives) {
    var k, v, _results;
    _results = [];
    for (k in object) {
      v = object[k];
      if (typeof v === 'object') {
        _results.push(Transparency.render(matchingElements(template, k), v, directives[k]));
      }
    }
    return _results;
  };

  setValue = function(element, value, attribute) {
    var t, text, _i, _len, _ref, _ref2;
    if (attribute) {
      return element.setAttribute(attribute, value);
    } else if ((element != null ? (_ref = element.t) != null ? _ref.text : void 0 : void 0) !== value) {
      _ref2 = filter((function(n) {
        return n.nodeType === TEXT_NODE;
      }), element.childNodes);
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        t = _ref2[_i];
        element.removeChild(t);
      }
      element.t || (element.t = {});
      element.t.text = value;
      text = document.createTextNode(value);
      if (element.firstChild) {
        return element.insertBefore(text, element.firstChild);
      } else {
        return element.appendChild(text);
      }
    }
  };

  matchingElements = function(template, key) {
    var firstChild, _base, _base2;
    if (!(firstChild = template.firstChild)) return [];
    firstChild.transparency || (firstChild.transparency = {});
    (_base = firstChild.transparency).queryCache || (_base.queryCache = {});
    return (_base2 = firstChild.transparency.queryCache)[key] || (_base2[key] = template.querySelectorAll ? template.querySelectorAll("#" + key + ", " + key + ", ." + key + ", [data-bind='" + key + "']") : filter(elementMatcher(key), template.getElementsByTagName('*')));
  };

  elementMatcher = function(key) {
    return function(element) {
      return element.id === key || element.nodeName.toLowerCase() === key.toLowerCase() || element.className.split(' ').indexOf(key) > -1 || element.getAttribute('data-bind') === key;
    };
  };

  TEXT_NODE = 3;

  if (typeof map === "undefined" || map === null) {
    map = function(f, xs) {
      var x, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = xs.length; _i < _len; _i++) {
        x = xs[_i];
        _results.push(f(x));
      }
      return _results;
    };
  }

  if (typeof filter === "undefined" || filter === null) {
    filter = function(p, xs) {
      var x, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = xs.length; _i < _len; _i++) {
        x = xs[_i];
        if (p(x)) _results.push(x);
      }
      return _results;
    };
  }

}).call(this);
