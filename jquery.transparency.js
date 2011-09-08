(function() {
  var $, assign;
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
  $.fn.render = function(data) {
    var context, template;
    if (!$.isArray(data)) {
      data = [data];
    }
    context = this;
    template = this.clone();
    $.each(data, function(index, object) {
      var tmp;
      tmp = template.clone();
      $.each(object, function(key, value) {
        var attribute, klass, _ref;
        if ($.isArray(value)) {
          return tmp.find("." + key).children().first().render(value);
        } else if (typeof value === "object") {
          return tmp.find("." + key).render(value);
        } else {
          _ref = key.split('@'), klass = _ref[0], attribute = _ref[1];
          if (tmp.hasClass(klass)) {
            assign(tmp, attribute, value);
          }
          return tmp.find("." + klass).each(function() {
            return assign($(this), attribute, value);
          });
        }
      });
      return context.before(tmp);
    });
    return context.remove();
  };
}).call(this);
