(function() {
  jQuery.fn.render = function(data) {
    var context, template;
    if (!jQuery.isArray(data)) {
      data = [data];
    }
    context = this;
    template = this.clone();
    jQuery.each(data, function(index, object) {
      var tmp;
      tmp = template.clone();
      jQuery.each(object, function(key, value) {
        var attribute, klass, _ref;
        if (jQuery.isArray(value)) {
          return tmp.find("." + key).children().first().render(value);
        } else {
          _ref = key.split('@'), klass = _ref[0], attribute = _ref[1];
          return tmp.find("." + klass).each(function() {
            if (attribute) {
              return jQuery(this).attr(attribute, value);
            } else {
              return jQuery(this).prepend(value);
            }
          });
        }
      });
      return context.before(tmp);
    });
    return context.remove();
  };
}).call(this);
