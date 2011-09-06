(function() {
  jQuery.fn.render = function(data) {
    return jQuery.fn.render = function(data) {
      var context, template;
      context = this;
      template = this.clone();
      if (!jQuery.isArray(data)) {
        data = [data];
      }
      context.empty();
      jQuery.each(data, function(index, object) {
        var tmp;
        tmp = template.clone();
        jQuery.each(object, function(key, value) {
          var attribute, klass, _ref;
          _ref = key.split('@'), klass = _ref[0], attribute = _ref[1];
          return tmp.find("." + klass).each(function() {
            if (attribute) {
              return jQuery(this).attr(attribute, value);
            } else {
              return jQuery(this).prepend(value);
            }
          });
        });
        return context.before(tmp);
      });
      return context.last().remove();
    };
  };
}).call(this);
