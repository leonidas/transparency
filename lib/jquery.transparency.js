(function() {
  var matchingElements, renderChildren, renderDirectives, renderForms, renderNode, renderValues;

  jQuery.fn.render = function(data, directives, parent) {
    var context, contexts, object, template, _i, _j, _len, _len2;
    contexts = this;
    if (!jQuery.isArray(data)) data = [data];
    directives || (directives = {});
    for (_i = 0, _len = contexts.length; _i < _len; _i++) {
      context = contexts[_i];
      context = jQuery(context);
      if (!context.data('template')) context.data('template', context.clone());
      context.empty();
      for (_j = 0, _len2 = data.length; _j < _len2; _j++) {
        object = data[_j];
        template = context.data('template').clone();
        template.data('key', context.data('key'));
        renderValues(template, object);
        renderForms(template, object);
        renderDirectives(template, object, directives);
        renderChildren(template, object, directives);
        context.append(template.children().clone(true, true));
      }
    }
    return contexts;
  };

  renderValues = function(template, object) {
    var key, node, value, _results;
    _results = [];
    for (key in object) {
      value = object[key];
      if (typeof value !== 'object') {
        _results.push((function() {
          var _i, _len, _ref, _results2;
          _ref = matchingElements(template, key);
          _results2 = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            node = _ref[_i];
            node = jQuery(node);
            node.data('data', object);
            _results2.push(renderNode(node, value));
          }
          return _results2;
        })());
      }
    }
    return _results;
  };

  renderForms = function(template, object) {
    var inputName, key, node, parentKey, value, _results;
    parentKey = template.data('key');
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
          _results2.push(renderNode(jQuery(node), value, 'value'));
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
          node = jQuery(node);
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
        _results.push(matchingElements(template, key).data('key', key).render(value, directives[key], object));
      }
    }
    return _results;
  };

  renderNode = function(node, value, attribute) {
    var children;
    if (attribute) {
      return node.attr(attribute, value);
    } else {
      children = node.children().detach();
      node.html(value);
      return node.append(children);
    }
  };

  matchingElements = function(template, key) {
    return template.find("." + key + ", #" + key + ", " + key).add(template.is("." + key + ", #" + key + ", " + key) ? template : void 0);
  };

}).call(this);
