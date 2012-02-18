(function() {
  var getTemplate, matchingElements, render, renderChildren, renderDirectives, renderNode, renderSimple, renderValues;

  jQuery.fn.render = function(objects, directives) {
    render(this.get(), objects, directives);
    return this;
  };

  window.render = render = function(contexts, objects, directives) {
    var context, i, instances, n, object, parent, template, _base, _base2, _base3, _i, _j, _len, _len2, _ref;
    if (typeof contexts.length !== 'number') contexts = [contexts];
    if (!(objects instanceof Array)) objects = [objects];
    directives || (directives = {});
    for (_i = 0, _len = contexts.length; _i < _len; _i++) {
      context = contexts[_i];
      context.t || (context.t = {});
      parent = (_base = context.t).parent || (_base.parent = context);
      instances = (_base2 = context.t).instances || (_base2.instances = []);
      (_base3 = context.t).template || (_base3.template = (function() {
        var _results;
        _results = [];
        while (n = context.firstChild) {
          _results.push(context.removeChild(n));
        }
        return _results;
      })());
      i = 0;
      while (i < objects.length) {
        object = objects[i];
        template = getTemplate(context, i);
        i += 1;
        renderSimple(template, object);
        renderValues(template, object);
        renderDirectives(template, object, directives);
        renderChildren(template, object, directives);
        while (n = template.firstChild) {
          context.appendChild(n);
        }
      }
      while (instances.length > objects.length) {
        _ref = instances.pop;
        for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
          n = _ref[_j];
          parent.removeChild(n);
        }
      }
    }
    return contexts;
  };

  getTemplate = function(context, i) {
    var instance, n, template, _i, _len, _ref;
    template = document.createElement('div');
    if (i < context.t.instances.length) {
      _ref = context.t.instances[i];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        n = _ref[_i];
        template.appendChild(n);
      }
      return template;
    } else {
      instance = (function() {
        var _j, _len2, _ref2, _results;
        _ref2 = context.t.template;
        _results = [];
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          n = _ref2[_j];
          _results.push(template.appendChild(n.cloneNode(true)));
        }
        return _results;
      })();
      context.t.instances.push(instance);
      return template;
    }
  };

  renderSimple = function(template, object) {
    var node;
    if (typeof object !== 'object') {
      node = template.querySelector(".listElement") || template.querySelector("*");
      return renderNode(node, object);
    }
  };

  renderValues = function(template, object) {
    var e, key, value, _results;
    _results = [];
    for (key in object) {
      value = object[key];
      if (typeof value !== 'object') {
        _results.push((function() {
          var _i, _len, _ref, _results2;
          _ref = matchingElements(template, key);
          _results2 = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            e = _ref[_i];
            _results2.push(renderNode(e, value));
          }
          return _results2;
        })());
      }
    }
    return _results;
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
          _results2.push(renderNode(node, directive.call(object, node), attribute));
        }
        return _results2;
      })());
    }
    return _results;
  };

  renderChildren = function(template, object, directives) {
    var key, value, _results;
    _results = [];
    for (key in object) {
      value = object[key];
      if (typeof value === 'object') {
        _results.push(render(matchingElements(template, key), value, directives[key]));
      }
    }
    return _results;
  };

  renderNode = function(element, value, attribute) {
    var n, t, _i, _len, _ref, _ref2;
    if (attribute) {
      return element.setAttribute(attribute, value);
    } else if ((element != null ? (_ref = element.t) != null ? _ref.text : void 0 : void 0) !== value) {
      _ref2 = (function() {
        var _j, _len, _ref2, _results;
        _ref2 = element.childNodes;
        _results = [];
        for (_j = 0, _len = _ref2.length; _j < _len; _j++) {
          n = _ref2[_j];
          if (n.nodeType === 3) _results.push(n);
        }
        return _results;
      })();
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        t = _ref2[_i];
        element.removeChild(t);
      }
      element.insertBefore(document.createTextNode(value), element.firstChild);
      element.t || (element.t = {});
      return element.t.text = value;
    }
  };

  matchingElements = function(template, key) {
    return template.querySelectorAll("#" + key + ", " + key + ", ." + key + ", [data-bind='" + key + "']");
  };

}).call(this);
