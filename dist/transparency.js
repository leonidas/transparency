(function() {
  var Context, ELEMENT_NODE, Instance, TEXT_NODE, Transparency, VOID_ELEMENTS, attr, cloneNode, consoleLogger, data, empty, expando, getChildNodes, getElements, getText, html5Clone, indexOf, isArray, isBoolean, isDate, isDomElement, isPlainValue, isVoidElement, log, nullLogger, setHtml, setSelected, setText, toString, _getElements, _ref,
    __hasProp = {}.hasOwnProperty,
    __slice = [].slice;

  Transparency = this.Transparency = {};

  Transparency.render = function(context, models, directives, options) {
    var log, _base;
    if (models == null) {
      models = [];
    }
    if (directives == null) {
      directives = {};
    }
    if (options == null) {
      options = {};
    }
    log = options.debug && console ? consoleLogger : nullLogger;
    log("Transparency.render:", context, models, directives, options);
    if (!context) {
      return;
    }
    if (!isArray(models)) {
      models = [models];
    }
    context = (_base = data(context)).context || (_base.context = new Context(context));
    return context.detach().render(models, directives, options).attach();
  };

  Transparency.jQueryPlugin = function(models, directives, options) {
    var context, _i, _len;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      context = this[_i];
      Transparency.render(context, models, directives, options);
    }
    return this;
  };

  Transparency.matcher = function(element, key) {
    return element.id === key || indexOf(element.className.split(' '), key) > -1 || element.name === key || element.getAttribute('data-bind') === key;
  };

  Transparency.clone = function(node) {
    var _base;
    return typeof (_base = jQuery || Zepto) === "function" ? _base(node).clone()[0] : void 0;
  };

  Context = (function() {

    function Context(el) {
      this.el = el;
      this.template = cloneNode(this.el);
      this.instances = [new Instance(this.el, this.el)];
      this.instanceCache = [];
    }

    Context.prototype.detach = function() {
      this.parent = this.el.parentNode;
      if (this.parent) {
        this.nextSibling = this.el.nextSibling;
        this.parent.removeChild(this.el);
      }
      return this;
    };

    Context.prototype.attach = function() {
      if (this.parent) {
        if (this.nextSibling) {
          this.parent.insertBefore(this.el, this.nextSibling);
        } else {
          this.parent.appendChild(this.el);
        }
      }
      return this;
    };

    Context.prototype.render = function(models, directives, options) {
      var index, instance, model, _i, _len;
      while (models.length < this.instances.length) {
        this.instanceCache.push(this.instances.pop().remove());
      }
      for (index = _i = 0, _len = models.length; _i < _len; index = ++_i) {
        model = models[index];
        if (!(instance = this.instances[index])) {
          instance = this.instanceCache.pop() || new Instance(cloneNode(this.template));
          this.instances.push(instance.appendTo(this.el));
        }
        instance.reset().render(model, index, directives, options);
      }
      return this;
    };

    return Context;

  })();

  Instance = (function() {

    function Instance(template) {
      this.queryCache = {};
      this.childNodes = getChildNodes(template);
      this.elements = getElements(template);
    }

    Instance.prototype.remove = function() {
      var node, _i, _len, _ref;
      _ref = this.childNodes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        node.parentNode.removeChild(node);
      }
      return this;
    };

    Instance.prototype.appendTo = function(parent) {
      var node, _i, _len, _ref;
      _ref = this.childNodes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        parent.appendChild(node);
      }
      return this;
    };

    Instance.prototype.reset = function() {
      var attribute, el, value, _i, _len, _ref, _ref1;
      _ref = this.elements;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        el = _ref[_i];
        _ref1 = data(el).originalAttributes;
        for (attribute in _ref1) {
          value = _ref1[attribute];
          attr(el, attribute, value);
        }
      }
      return this;
    };

    Instance.prototype.render = function(model, index, directives, options) {
      var children, element, key, nodeName, value, _i, _len, _ref;
      children = [];
      this.assoc(model);
      if (isDomElement(model) && (element = this.elements[0])) {
        empty(element).appendChild(model);
      } else if (typeof model === 'object') {
        for (key in model) {
          if (!__hasProp.call(model, key)) continue;
          value = model[key];
          if (value != null) {
            if (isPlainValue(value)) {
              _ref = this.matchingElements(key);
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                element = _ref[_i];
                nodeName = element.nodeName.toLowerCase();
                if (nodeName === 'input') {
                  attr(element, 'value', value);
                } else if (nodeName === 'select') {
                  attr(element, 'selected', value);
                } else {
                  attr(element, 'text', value);
                }
              }
            } else if (typeof value === 'object') {
              children.push(key);
            }
          }
        }
      }
      return this.renderDirectives(model, index, directives).renderChildren(model, children, directives, options);
    };

    Instance.prototype.assoc = function(model) {
      var el, _i, _len, _ref, _results;
      _ref = this.elements;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        el = _ref[_i];
        _results.push(data(el).model = model);
      }
      return _results;
    };

    Instance.prototype.renderValues = function() {};

    Instance.prototype.renderDirectives = function(model, index, directives) {
      var attribute, attributes, directive, element, key, value, _i, _len, _ref;
      if (!directives) {
        return this;
      }
      model = typeof model === 'object' ? model : {
        value: model
      };
      for (key in directives) {
        if (!__hasProp.call(directives, key)) continue;
        attributes = directives[key];
        if (typeof attributes === 'object') {
          _ref = this.matchingElements(key);
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            element = _ref[_i];
            for (attribute in attributes) {
              directive = attributes[attribute];
              if (!(typeof directive === 'function')) {
                continue;
              }
              value = directive.call(model, {
                element: element,
                index: index,
                value: attr(element, attribute)
              });
              attr(element, attribute, value);
            }
          }
        }
      }
      return this;
    };

    Instance.prototype.renderChildren = function(model, children, directives, options) {
      var element, key, _i, _j, _len, _len1, _ref;
      for (_i = 0, _len = children.length; _i < _len; _i++) {
        key = children[_i];
        _ref = this.matchingElements(key);
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          element = _ref[_j];
          Transparency.render(element, model[key], directives[key], options);
        }
      }
      return this;
    };

    Instance.prototype.matchingElements = function(key) {
      var e, elements, _base;
      elements = (_base = this.queryCache)[key] || (_base[key] = (function() {
        var _i, _len, _ref, _results;
        _ref = this.elements;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          e = _ref[_i];
          if (Transparency.matcher(e, key)) {
            _results.push(e);
          }
        }
        return _results;
      }).call(this));
      log("Matching elements for '" + key + "':", elements);
      return elements;
    };

    return Instance;

  })();

  getChildNodes = function(el) {
    var child, childNodes;
    childNodes = [];
    child = el.firstChild;
    while (child) {
      childNodes.push(child);
      child = child.nextSibling;
    }
    return childNodes;
  };

  getElements = function(el) {
    var elements;
    elements = [];
    _getElements(el, elements);
    return elements;
  };

  _getElements = function(template, elements) {
    var child, _base, _results;
    child = template.firstChild;
    _results = [];
    while (child) {
      if (child.nodeType === ELEMENT_NODE) {
        (_base = data(child)).originalAttributes || (_base.originalAttributes = {});
        elements.push(child);
        _getElements(child, elements);
      }
      _results.push(child = child.nextSibling);
    }
    return _results;
  };

  setHtml = function(element, html) {
    var child, elementData, n, _i, _len, _ref, _results;
    elementData = data(element);
    if (elementData.html === html) {
      return;
    }
    elementData.html = html;
    elementData.children || (elementData.children = (function() {
      var _i, _len, _ref, _results;
      _ref = element.childNodes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        n = _ref[_i];
        if (n.nodeType === ELEMENT_NODE) {
          _results.push(n);
        }
      }
      return _results;
    })());
    empty(element);
    element.innerHTML = html;
    _ref = elementData.children;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      child = _ref[_i];
      _results.push(element.appendChild(child));
    }
    return _results;
  };

  setText = function(element, text) {
    var elementData, textNode;
    elementData = data(element);
    if (!(text != null) || elementData.text === text) {
      return;
    }
    elementData.text = text;
    textNode = element.firstChild;
    if (!textNode) {
      return element.appendChild(element.ownerDocument.createTextNode(text));
    } else if (textNode.nodeType !== TEXT_NODE) {
      return element.insertBefore(element.ownerDocument.createTextNode(text), textNode);
    } else {
      return textNode.nodeValue = text;
    }
  };

  getText = function(element) {
    var child;
    return ((function() {
      var _i, _len, _ref, _results;
      _ref = element.childNodes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        if (child.nodeType === TEXT_NODE) {
          _results.push(child.nodeValue);
        }
      }
      return _results;
    })()).join('');
  };

  setSelected = function(element, value) {
    var child, childElements, _i, _len, _results;
    value = value.toString();
    childElements = [];
    childElements = getElements(element);
    _results = [];
    for (_i = 0, _len = childElements.length; _i < _len; _i++) {
      child = childElements[_i];
      if (child.nodeName.toLowerCase() === 'option') {
        if (child.value === value) {
          _results.push(child.selected = true);
        } else {
          _results.push(child.selected = false);
        }
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  attr = function(element, attribute, value) {
    var elementData, _base, _base1, _base2, _base3, _base4, _ref, _ref1, _ref2, _ref3, _ref4;
    elementData = data(element);
    if (value == null) {
      return elementData.originalAttributes[attribute];
    }
    if (element.nodeName.toLowerCase() === 'select' && attribute === 'selected') {
      return setSelected(element, value);
    } else {
      switch (attribute) {
        case 'text':
          if (!isVoidElement(element)) {
            if ((_ref = (_base = elementData.originalAttributes)['text']) == null) {
              _base['text'] = getText(element);
            }
            return setText(element, value);
          }
          break;
        case 'html':
          if ((_ref1 = (_base1 = elementData.originalAttributes)['html']) == null) {
            _base1['html'] = element.innerHTML;
          }
          return setHtml(element, value);
        case 'class':
          if ((_ref2 = (_base2 = elementData.originalAttributes)['class']) == null) {
            _base2['class'] = element.className;
          }
          return element.className = value;
        default:
          element[attribute] = value;
          if (isBoolean(value)) {
            if ((_ref3 = (_base3 = elementData.originalAttributes)[attribute]) == null) {
              _base3[attribute] = element.getAttribute(attribute) || false;
            }
            if (value) {
              return element.setAttribute(attribute, attribute);
            } else {
              return element.removeAttribute(attribute);
            }
          } else {
            if ((_ref4 = (_base4 = elementData.originalAttributes)[attribute]) == null) {
              _base4[attribute] = element.getAttribute(attribute) || "";
            }
            return element.setAttribute(attribute, value.toString());
          }
      }
    }
  };

  empty = function(element) {
    var child;
    while (child = element.firstChild) {
      element.removeChild(child);
    }
    return element;
  };

  ELEMENT_NODE = 1;

  TEXT_NODE = 3;

  VOID_ELEMENTS = ["area", "base", "br", "col", "command", "embed", "hr", "img", "input", "keygen", "link", "meta", "param", "source", "track", "wbr"];

  html5Clone = function() {
    return document.createElement("nav").cloneNode(true).outerHTML !== "<:nav></:nav>";
  };

  cloneNode = !(typeof document !== "undefined" && document !== null) || html5Clone() ? function(node) {
    return node.cloneNode(true);
  } : function(node) {
    var cloned, element, _i, _len, _ref;
    cloned = Transparency.clone(node);
    if (cloned.nodeType === ELEMENT_NODE) {
      cloned.removeAttribute(expando);
      _ref = cloned.getElementsByTagName('*');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        element = _ref[_i];
        element.removeAttribute(expando);
      }
    }
    return cloned;
  };

  expando = 'transparency';

  data = function(element) {
    return element[expando] || (element[expando] = {});
  };

  nullLogger = function() {};

  consoleLogger = function() {
    var messages;
    messages = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return console.log.apply(console, messages);
  };

  log = nullLogger;

  toString = Object.prototype.toString;

  isDate = function(obj) {
    return toString.call(obj) === '[object Date]';
  };

  isDomElement = function(obj) {
    return obj.nodeType === ELEMENT_NODE;
  };

  isVoidElement = function(el) {
    return indexOf(VOID_ELEMENTS, el.nodeName.toLowerCase()) > -1;
  };

  isPlainValue = function(obj) {
    return isDate(obj) || typeof obj !== 'object' && typeof obj !== 'function';
  };

  isBoolean = function(obj) {
    return obj === true || obj === false;
  };

  isArray = Array.isArray || function(obj) {
    return toString.call(obj) === '[object Array]';
  };

  indexOf = function(array, item) {
    var i, x, _i, _len;
    if (array.indexOf) {
      return array.indexOf(item);
    }
    for (i = _i = 0, _len = array.length; _i < _len; i = ++_i) {
      x = array[i];
      if (x === item) {
        return i;
      }
    }
    return -1;
  };

  if ((_ref = jQuery || Zepto) != null) {
    _ref.fn.render = Transparency.jQueryPlugin;
  }

  if (typeof define !== "undefined" && define !== null ? define.amd : void 0) {
    define(function() {
      return Transparency;
    });
  }

}).call(this);
