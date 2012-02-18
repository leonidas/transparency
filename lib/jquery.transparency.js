(function() {
  var matchingElements, renderChildren, renderDirectives, renderForms, renderNode, renderSimple, renderValues;

  jQuery.fn.render = function(objects, directives, parentKey) {
    var context, contexts, object, template, _i, _j, _len, _len2;
    contexts = this;
    if (!(objects instanceof Array)) objects = [objects];
    directives || (directives = {});
    for (_i = 0, _len = contexts.length; _i < _len; _i++) {
      context = contexts[_i];
      context = jQuery(context);
      if (!context.data('template')) context.data('template', context.clone());
      context.empty();
      for (_j = 0, _len2 = objects.length; _j < _len2; _j++) {
        object = objects[_j];
        template = context.data('template').clone();
        renderSimple(template, object);
        renderValues(template, object);
        renderForms(template, object, parentKey);
        renderDirectives(template, object, directives);
        renderChildren(template, object, directives);
        context.append(template.children());
      }
    }
    return contexts;
  };

  renderSimple = function(template, object) {
    var node;
    if (typeof object !== 'object') {
      node = template.find(".listElement").get(0) || template.children().get(0);
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

  renderForms = function(template, object, parentKey) {
    var inputName, key, node, value, _results;
    if (!parentKey) return;
    _results = [];
    for (key in object) {
      value = object[key];
      if (!(typeof value !== 'object')) continue;
      inputName = "" + parentKey + "\\[" + key + "\\]";
      if (template.is('input') && template.attr('name') === inputName && template.attr('type') === 'text') {
        renderNode(template, value, 'value');
      }
      _results.push((function() {
        var _i, _len, _ref, _results2;
        _ref = template.find("input[name=" + inputName + "]");
        _results2 = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          node = _ref[_i];
          _results2.push(renderNode(node, value, 'value'));
        }
        return _results2;
      })());
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
        _results.push(matchingElements(template, key).render(value, directives[key], key));
      }
    }
    return _results;
  };

  renderNode = function(element, value, attribute) {
    var n, t, _i, _len, _ref;
    if (attribute) {
      return element.setAttribute(attribute, value);
    } else {
      _ref = (function() {
        var _j, _len, _ref, _results;
        _ref = element.childNodes;
        _results = [];
        for (_j = 0, _len = _ref.length; _j < _len; _j++) {
          n = _ref[_j];
          if (n.nodeType === 3) _results.push(n);
        }
        return _results;
      })();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        t = _ref[_i];
        element.removeChild(t);
      }
      return element.insertBefore(document.createTextNode(value), element.firstChild);
    }
  };

  matchingElements = function(template, key) {
    return template.find("#" + key + ", " + key + ", ." + key + ", [data-bind='" + key + "']");
  };

}).call(this);
