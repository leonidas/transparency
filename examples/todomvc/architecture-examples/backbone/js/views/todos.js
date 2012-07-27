$(function() {
	'use strict';

	// Todo Item View
	// --------------

	// The DOM element for a todo item...
	window.app.TodoView = Backbone.View.extend({

		// The DOM events specific to an item.
		events: {
			"click .toggle"   : "togglecompleted",
			"dblclick .view"  : "edit",
			"click .destroy"  : "destroy",
			"keypress .edit"  : "updateOnEnter",
			"blur .edit"      : "close"
		},

		// The TodoView listens for changes to its model, re-rendering. Since there's
		// a one-to-one correspondence between a **Todo** and a **TodoView** in this
		// app, we set a direct reference on the model for convenience.
		initialize: function() {
			this.model.on('change',  this.render, this);
			this.model.on('destroy', this.remove, this);
		},

		// Re-render the titles of the todo item.
		render: function() {
			var $el = $(this.el);
			$el.render(this.model.toJSON(), {
				toggle: { checked: function(p) {
				      p.element.checked = this.completed;
				    }
				  }
				});

			$el.toggleClass('completed', this.model.get('completed'));

			this.input = this.$('.edit');
			return this;
		},

		// Toggle the `"completed"` state of the model.
		togglecompleted: function() {
			this.model.toggle();
		},

		// Switch this view into `"editing"` mode, displaying the input field.
		edit: function() {
			$(this.el).addClass("editing");
			this.input.focus();
		},

		// Close the `"editing"` mode, saving changes to the todo.
		close: function() {
			var value = this.input.val().trim();

			if ( !value ){
				this.clear();
			}

			this.model.save({title: value});
			$(this.el).removeClass("editing");
		},

		// If you hit `enter`, we're through editing the item.
		updateOnEnter: function(e) {
			if ( e.keyCode === ENTER_KEY ){
				this.close();
			}
		},

		// Destroy the model.
		destroy: function() {
			this.model.destroy();
		}
	});

});
