(function() {
  var assignValue, renderKey, select, validAttribute;
  renderKey = function(key, value, buffer) {
    var attribute, element, klass, _, _ref, _ref2;
    _ref2 = (_ref = key.split('@'), element = _ref[0], _ = _ref[1], _ref), klass = _ref2[0], attribute = _ref2[1];
    if (buffer.hasClass(klass || buffer.is(element))) {
      assignValue(buffer, attribute, value);
    }
    return buffer.find("" + element + ", ." + klass).each(function() {
      return assignValue(jQuery(this), attribute, value);
    });
  };
  assignValue = function(node, attribute, value) {
    var children;
    if (attribute) {
      if (!validAttribute(attribute)) {
        throw "" + attribute + ": Unsafe attribute assignment";
      }
      return node.attr(attribute, value);
    } else {
      children = node.children().detach();
      node.text(value);
      return node.append(children);
    }
  };
  validAttribute = function(attribute) {
    var valid, valids;
    valids = [/^src$/, /^alt$/, 'id', /^href$/, /^class$/, /^data-*/];
    return ((function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = valids.length; _i < _len; _i++) {
        valid = valids[_i];
        if (attribute.match(valid)) {
          _results.push(true);
        }
      }
      return _results;
    })()).length === 1;
  };
  select = function(object, fn) {
    var key, result, value;
    result = {};
    for (key in object) {
      value = object[key];
      if (fn(key, value)) {
        result[key] = value;
      }
    }
    return result;
  };
  jQuery.fn.render = function(data, directives) {
    var buffer, context, directive, key, klass, local_directives, local_values, object, objects, template, value, _i, _len;
    if (directives == null) {
      directives = {};
    }
    context = jQuery.isArray(data) ? this.children().first() : this;
    template = context.clone();
    if (!jQuery.isArray(data)) {
      data = [data];
    }
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      object = data[_i];
      local_values = select(object, function(key, value) {
        return typeof value === 'string';
      });
      local_directives = select(directives, function(key, directive) {
        return typeof directive === 'function';
      });
      objects = select(object, function(key, value) {
        return typeof value === 'object';
      });
      buffer = template.clone();
      for (key in local_values) {
        value = local_values[key];
        renderKey(key, value, buffer);
      }
      for (key in local_directives) {
        directive = local_directives[key];
        value = directive.call(object);
        renderKey(key, value, buffer);
      }
      for (klass in objects) {
        value = objects[klass];
        buffer.find("." + klass).add(key).render(value, directives[klass]);
      }
      context.before(buffer);
    }
    return context.remove();
  };
}).call(this);
