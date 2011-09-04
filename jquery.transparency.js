(function() {
  jQuery.fn.render = function(data) {
    var parent, template;
    if (!jQuery.isArray(data)) {
      data = [data];
    }
    parent = this.parent();
    template = this.clone();
    this.remove();
    _(data).each(function(object) {
      template = template.clone();
      _(object).chain().keys().each(function(key) {
        var attribute, klass, tmp;
        tmp = key.split('@');
        klass = tmp[0];
        if (tmp.length > 1) {
          attribute = tmp[1];
        }
        return template.find("." + klass).each(function() {
          if (attribute) {
            return jQuery(this).attr(attribute, object[key]);
          } else {
            return jQuery(this).text(object[key]);
          }
        });
      });
      return parent.append(template);
    });
    return parent;
  };
}).call(this);
