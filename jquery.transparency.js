(function() {
  var $, assign, select;
  $ = jQuery;
  assign = function(node, attribute, value) {
    var children;
    if (attribute) {
      return node.attr(attribute, value);
    } else {
      children = node.children().detach();
      node.text(value);
      return node.append(children);
    }
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
  $.fn.render = function(data) {
    var attribute, context, key, klass, lists, object, objects, result, template, value, values, _i, _len, _ref;
    if (!$.isArray(data)) {
      data = [data];
    }
    context = this;
    template = this.clone();
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      object = data[_i];
      values = select(object, function(key, value) {
        return typeof value === "string";
      });
      objects = select(object, function(key, value) {
        return typeof value === "object" && !$.isArray(value);
      });
      lists = select(object, function(key, value) {
        return $.isArray(value);
      });
      result = template.clone();
      for (key in values) {
        value = values[key];
        _ref = key.split('@'), klass = _ref[0], attribute = _ref[1];
        if (result.hasClass(klass)) {
          assign(result, attribute, value);
        }
        result.find("." + klass).each(function() {
          return assign($(this), attribute, value);
        });
      }
      for (key in lists) {
        value = lists[key];
        result.find("." + key).children().first().render(value);
      }
      for (key in objects) {
        value = objects[key];
        result.find("." + key).render(value);
      }
      context.before(result);
    }
    return context.remove();
  };
}).call(this);
