(function() {
  var renderChildren, renderDirectives, renderNode, renderValues;
  renderValues = function(buffer, object) {
    var key, node, value, _results;
    _results = [];
    for (key in object) {
      value = object[key];
      if (typeof value === 'string') {
        if (buffer.hasClass(key || buffer.is(key))) {
          renderNode(buffer, value);
        }
        _results.push((function() {
          var _i, _len, _ref, _results2;
          _ref = buffer.find("" + key + ", ." + key);
          _results2 = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            node = _ref[_i];
            _results2.push(renderNode(jQuery(node), value));
          }
          return _results2;
        })());
      }
    }
    return _results;
  };
  renderDirectives = function(buffer, object, directives) {
    var attribute, directive, key, node, _ref, _results;
    _results = [];
    for (key in directives) {
      directive = directives[key];
      if (typeof directive === 'function') {
        _ref = key.split('@'), key = _ref[0], attribute = _ref[1];
        if (buffer.hasClass(key || buffer.is(key))) {
          renderNode(buffer, directive.call(object, buffer), attribute);
        }
        _results.push((function() {
          var _i, _len, _ref2, _results2;
          _ref2 = buffer.find("" + key + ", ." + key);
          _results2 = [];
          for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
            node = _ref2[_i];
            node = jQuery(node);
            _results2.push(renderNode(node, directive.call(object, node), attribute));
          }
          return _results2;
        })());
      }
    }
    return _results;
  };
  renderChildren = function(buffer, object, directives) {
    var key, value, _results;
    _results = [];
    for (key in object) {
      value = object[key];
      if (typeof value === 'object' && key !== 'parent_') {
        if (buffer.hasClass(key)) {
          buffer.render(value, directives[key], object);
        }
        _results.push(buffer.find("." + key).render(value, directives[key], object));
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
      node.text(value);
      return node.append(children);
    }
  };
  jQuery.fn.render = function(data, directives, parent) {
    var buffer, context, contexts, object, result, template, _i, _j, _len, _len2;
    directives || (directives = {});
    result = this;
    contexts = jQuery.isArray(data) ? this.children() : [this];
    for (_i = 0, _len = contexts.length; _i < _len; _i++) {
      context = contexts[_i];
      context = jQuery(context);
      template = context.clone();
      if (!jQuery.isArray(data)) {
        data = [data];
      }
      for (_j = 0, _len2 = data.length; _j < _len2; _j++) {
        object = data[_j];
        object.parent_ = parent;
        buffer = template.clone();
        renderValues(buffer, object);
        renderDirectives(buffer, object, directives);
        renderChildren(buffer, object, directives);
        context.before(buffer);
      }
      context.remove();
    }
    return result;
  };
}).call(this);
