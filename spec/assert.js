(function() {
  var expect, trim;

  trim = function(text) {
    return text.replace(/\s/g, '').toLowerCase();
  };

  expect = function(actual) {
    return {
      toBeEqual: function(expected) {
        var actualAttr, actualChildren, attribute, child, expectedAttr, expectedChildren, i, j, k, len, len1, ref, results;
        if (trim(actual.text()) !== trim(expected.text())) {
          throw new Error("ERROR: '" + (actual.text()) + "' is not equal to '" + (expected.text()) + "'");
        }
        ref = expected[0].attributes;
        for (j = 0, len = ref.length; j < len; j++) {
          attribute = ref[j];
          actualAttr = actual[0].getAttribute(attribute.name);
          if (actualAttr == null) {
            throw new Error("ERROR: Missing expected attribute '" + attribute.name + "'");
          }
          actualAttr = trim(actualAttr);
          expectedAttr = trim(expected[0].getAttribute(attribute.name));
          if (actualAttr !== expectedAttr) {
            throw new Error("ERROR: '" + attribute.name + "=\"" + actualAttr + "\"' is not equal to '" + expectedAttr + "\"'");
          }
        }
        actualChildren = actual.children();
        expectedChildren = expected.children();
        if (expectedChildren.length !== actualChildren.length) {
          throw new Error("Expected children count " + expectedChildren.length + " is not equal to actual children count " + actualChildren.length);
        }
        results = [];
        for (i = k = 0, len1 = expectedChildren.length; k < len1; i = ++k) {
          child = expectedChildren[i];
          results.push(expect($(actualChildren[i])).toBeEqual($(child)));
        }
        return results;
      },
      toEqual: function(expected) {
        if (actual !== expected) {
          throw new Error(actual + " != " + expected);
        }
      },
      toBeOnTheSameBallpark: function(expected, ballpark) {
        var message, passed;
        message = ("Expected " + actual.name + " (" + actual.stats.mean + " +/- " + actual.stats.moe + " to be less than ") + (ballpark + " x " + expected.name + " (" + expected.stats.mean + " +/- " + expected.stats.moe);
        console.log(actual.toString());
        console.log(expected.toString());
        passed = actual.stats.mean + actual.stats.moe < ballpark * expected.stats.mean + actual.stats.moe;
        if (!passed) {
          throw new Error(message);
        }
      },
      toBeDefined: function() {
        if (actual == null) {
          throw Error("Variable not defined: " + actual);
        }
      }
    };
  };

  this.expect = expect;

}).call(this);
