(function() {
  var renderChildren, renderDirectives, renderForms, renderNode, renderValues;
  jQuery.fn.render = function(data, directives, parent) {
    var context, contexts, object, template, _i, _j, _len, _len2;
    contexts = this;
    if (!jQuery.isArray(data)) {
      data = [data];
    }
    directives || (directives = {});
    for (_i = 0, _len = contexts.length; _i < _len; _i++) {
      context = contexts[_i];
      context = jQuery(context);
      if (!context.data('template')) {
        context.data('template', context.clone());
      }
      context.empty();
      for (_j = 0, _len2 = data.length; _j < _len2; _j++) {
        object = data[_j];
        if (object) {
          object.parent_ = parent;
        }
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
    var key, node, renderables, value, _results;
    _results = [];
    for (key in object) {
      value = object[key];
      if (typeof value === 'string') {
        renderables = template.find("." + key).add(template.hasClass(key || template.is(key)) ? template : void 0);
        _results.push((function() {
          var _i, _len, _results2;
          _results2 = [];
          for (_i = 0, _len = renderables.length; _i < _len; _i++) {
            node = renderables[_i];
            node = jQuery(node);
            node.data('object', object);
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
    if (!parentKey) {
      return;
    }
    _results = [];
    for (key in object) {
      value = object[key];
      if (typeof value === 'string') {
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
    }
    return _results;
  };
  renderDirectives = function(template, object, directives) {
    var attribute, directive, key, node, renderables, _ref, _results;
    _results = [];
    for (key in directives) {
      directive = directives[key];
      if (typeof directive === 'function') {
        _ref = key.split('@'), key = _ref[0], attribute = _ref[1];
        renderables = template.find("." + key).add(template.hasClass(key || template.is(key)) ? template : void 0);
        _results.push((function() {
          var _i, _len, _results2;
          _results2 = [];
          for (_i = 0, _len = renderables.length; _i < _len; _i++) {
            node = renderables[_i];
            node = jQuery(node);
            _results2.push(renderNode(node, directive.call(object, node), attribute));
          }
          return _results2;
        })());
      }
    }
    return _results;
  };
  renderChildren = function(template, object, directives) {
    var key, renderables, value, _results;
    _results = [];
    for (key in object) {
      value = object[key];
      if (typeof value === 'object' && key !== 'parent_') {
        _results.push(renderables = template.find("." + key).add(template.hasClass(key) ? template : void 0).data('key', key).render(value, directives[key], object));
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
}).call(this);
