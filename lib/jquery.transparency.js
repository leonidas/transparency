(function() {
  var TEXT_NODE, Transparency, matchingElements, renderChildren, renderDirectives, renderValues, setValue;

  if (typeof jQuery !== "undefined" && jQuery !== null) {
    jQuery.fn.render = function(objects, directives) {
      Transparency.render(this.get(), objects, directives);
      return this;
    };
  }

  Transparency = this.Transparency = {};

  Transparency.render = function(contexts, objects, directives) {
    var c, i, n, object, parent, sibling, template, _base, _base2, _base3, _i, _j, _k, _len, _len2, _len3, _ref, _ref2;
    contexts = contexts.length != null ? Array.prototype.slice.call(contexts, 0) : [contexts];
    if (!(objects instanceof Array)) objects = [objects];
    directives || (directives = {});
    template = document.createElement('div');
    for (_i = 0, _len = contexts.length; _i < _len; _i++) {
      c = contexts[_i];
      c.t || (c.t = {});
      (_base = c.t).instances || (_base.instances = []);
      (_base2 = c.t).tc || (_base2.tc = []);
      (_base3 = c.t).template || (_base3.template = ((function() {
        var _results;
        _results = [];
        while (n = c.firstChild) {
          _results.push(c.removeChild(n));
        }
        return _results;
      })()));
      sibling = c.nextSibling;
      parent = c.parentNode;
      if (parent != null) parent.removeChild(c);
      while (objects.length > c.t.instances.length) {
        c.t.instances.push(c.t.tc.pop() || map((function(n) {
          return n.cloneNode(true);
        }), c.t.template));
      }
      while (objects.length < c.t.instances.length) {
        _ref = c.t.instances.pop();
        for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
          n = _ref[_j];
          c.t.tc.push(n.removeChild(n));
        }
      }
      for (i in objects) {
        object = objects[i];
        _ref2 = c.t.instances[i];
        for (_k = 0, _len3 = _ref2.length; _k < _len3; _k++) {
          n = _ref2[_k];
          template.appendChild(n);
        }
        renderValues(template, object);
        renderDirectives(template, object, directives);
        renderChildren(template, object, directives);
        while (n = template.firstChild) {
          c.appendChild(n);
        }
      }
      if (sibling) {
        if (parent != null) parent.insertBefore(c, sibling);
      } else {
        if (parent != null) parent.appendChild(c);
      }
    }
    return contexts;
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
    var fc, t, text, _i, _len, _ref, _ref2;
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
      if (fc = element.firstChild) {
        return element.insertBefore(text, fc);
      } else {
        return element.appendChild(text);
      }
    }
  };

  matchingElements = function(template, key) {
    var fc, p, _base, _base2;
    if (!(fc = template.firstChild)) return [];
    fc.t || (fc.t = {});
    (_base = fc.t).qc || (_base.qc = {});
    return (_base2 = fc.t.qc)[key] || (_base2[key] = template.querySelectorAll ? template.querySelectorAll("#" + key + ", " + key + ", ." + key + ", [data-bind='" + key + "']") : (p = function(e) {
      return e.id === key ||  e.nodeName.toLowerCase() === key.toLowerCase() || e.className.split(' ').indexOf(key) > -1 ||  e.getAttribute('data-bind') === key;
    }, filter(p, template.getElementsByTagName('*'))));
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
