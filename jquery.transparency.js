(function() {
  var assignValue, renderKey, validAttribute;
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
    valids = ['src', 'alt', 'id', 'href', 'class', /^data-*/];
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
  jQuery.fn.render = function(data, directives) {
    var buffer, context, contexts, directive, key, klass, object, original, template, value, _i, _j, _len, _len2;
    directives || (directives = {});
    original = this;
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
        buffer = template.clone();
        for (key in object) {
          value = object[key];
          if (typeof value === 'string') {
            renderKey(key, value, buffer);
          }
        }
        for (key in directives) {
          directive = directives[key];
          if (typeof directive === 'function') {
            value = directive.call(object);
            renderKey(key, value, buffer);
          }
        }
        for (klass in object) {
          value = object[klass];
          if (typeof value === 'object') {
            if (buffer.hasClass(klass)) {
              buffer.render(value, directives[klass]);
            }
            buffer.find("." + klass).add(key).render(value, directives[klass]);
          }
        }
        context.before(buffer);
      }
      context.remove();
    }
    return original;
  };
}).call(this);
