(function() {
  $(document).ready(function() {
    var state, updateCode;
    state = {
      example: "assigning-values",
      template: "jade",
      code: "coffee"
    };
    $('#code, #template').keyup(function() {
      var code, template;
      code = $('#code').val();
      template = $('#template').val();
      try {
        if (state.template === "jade") {
          template = jade.compile(template)();
        }
        $('#result').empty().append(template);
        if (state.code === "coffee") {
          code = CoffeeScript.compile(code, {
            bare: true
          });
        }
        eval(code);
        $('#source').empty().text(style_html($('#result').html(), {
          indent_size: 2
        }));
        prettyPrint();
        return $('#error').empty();
      } catch (error) {
        return $('#error').text(error.message);
      }
    });
    $('.option').click(function(event) {
      var option;
      event.preventDefault();
      $(this).siblings().removeClass('active');
      $(this).addClass('active');
      option = $(event.target).attr('id');
      console.log(option);
      switch (option) {
        case "jade":
        case "html":
          state.template = option;
          break;
        case "coffee":
        case "javascript":
          state.code = option;
      }
      return updateCode();
    });
    $('#examples').click(function(event) {
      event.preventDefault();
      state.example = $(event.target).attr('id');
      return updateCode();
    });
    updateCode = function() {
      switch (state.code) {
        case "coffee":
          $('#code').val(window.examples[state.example]["coffee"]);
          break;
        default:
          $('#code').val(CoffeeScript.compile(window.examples[state.example]["coffee"], {
            bare: true
          }));
      }
      switch (state.template) {
        case "jade":
          $('#template').val(window.examples[state.example]["jade"]);
          break;
        default:
          $('#template').val(style_html(jade.compile(window.examples[state.example]["jade"])(), {
            indent_size: 2
          }));
      }
      return $('#code').trigger('keyup');
    };
    return $('#examples a').first().trigger('click');
  });
}).call(this);
