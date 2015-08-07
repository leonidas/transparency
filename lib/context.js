var Context, Instance, after, before, chainable, cloneNode, ref;

ref = require('./helpers'), before = ref.before, after = ref.after, chainable = ref.chainable, cloneNode = ref.cloneNode;

Instance = require('./instance');

module.exports = Context = (function() {
  var attach, detach;

  detach = chainable(function() {
    this.parent = this.el.parentNode;
    if (this.parent) {
      this.nextSibling = this.el.nextSibling;
      return this.parent.removeChild(this.el);
    }
  });

  attach = chainable(function() {
    if (this.parent) {
      if (this.nextSibling) {
        return this.parent.insertBefore(this.el, this.nextSibling);
      } else {
        return this.parent.appendChild(this.el);
      }
    }
  });

  function Context(el, Transparency) {
    this.el = el;
    this.Transparency = Transparency;
    this.template = cloneNode(this.el);
    this.instances = [new Instance(this.el, this.Transparency)];
    this.instanceCache = [];
  }

  Context.prototype.render = before(detach)(after(attach)(chainable(function(models, directives, options) {
    var children, i, index, instance, len, model, results;
    while (models.length < this.instances.length) {
      this.instanceCache.push(this.instances.pop().remove());
    }
    while (models.length > this.instances.length) {
      instance = this.instanceCache.pop() || new Instance(cloneNode(this.template), this.Transparency);
      this.instances.push(instance.appendTo(this.el));
    }
    results = [];
    for (index = i = 0, len = models.length; i < len; index = ++i) {
      model = models[index];
      instance = this.instances[index];
      children = [];
      results.push(instance.prepare(model, children).renderValues(model, children).renderDirectives(model, index, directives).renderChildren(model, children, directives, options));
    }
    return results;
  })));

  return Context;

})();
