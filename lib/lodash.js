 var _ = {};

_.toString = Object.prototype.toString;

_.toArray = function(obj) {
  var arr = new Array(obj.length);
  for (var i = 0; i < obj.length; i++) {
    arr[i] = obj[i];
  }
  return arr;
};

_.isString = function(obj) { return _.toString.call(obj) == '[object String]'; };

_.isNumber = function(obj) { return _.toString.call(obj) == '[object Number]'; };

_.isArray = Array.isArray || function(obj) {
  return _.toString.call(obj) === '[object Array]';
};

_.isDate = function(obj) {
  return _.toString.call(obj) === '[object Date]';
};

_.isElement = function(obj) {
  return !!(obj && obj.nodeType === 1);
};

_.isPlainValue = function(obj) {
  var type;
  type = typeof obj;
  return (type !== 'object' && type !== 'function') || exports.isDate(obj);
};

_.isBoolean = function(obj) {
  return obj === true || obj === false;
};

module.exports = _;
