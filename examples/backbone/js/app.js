$(function() {
	var CustomersView, CustomerRowView, CustomerModel, CustomerCollection;

	CustomerModel = Backbone.Model.extend({

	});

	CustomerCollection = Backbone.Collection.extend({
		model: CustomerModel,
		url: 'customers.json'
	});

	CustomerRowView = Backbone.View.extend({
		tagName: 'tr',
		events: {
			'click .delete': 'deleteModel'
		},
		templateBase: $('#templates .tmpl-customerrow').detach(),
		initialize: function() {
			this.template = this.templateBase.clone();
		},
		render: function() {
			data = this.model.toJSON();
			this.$el.html(this.template.render(data).children());
			return this;
		},
		deleteModel: function() {
			//Here you would actually call this.model.destroy() and you would
			//have a callback for the "destroy" event
			alert('Removing');
			return false;
		}
	});

	CustomersView = Backbone.View.extend({
		events: {
			'submit .new-customer': 'addNewCustomer'
		},
		el: $('#application'),
		templateBase: $('#templates > .tmpl-customers').detach(),
		render: function() {
			var data = {
				suffixes: ['Ms.', 'Mrs.', 'Mr.']
			}, directives = {
				suffixes: {
					suffix: {
						html: function() {
							return this.value;
						}
					}
				}
			};
			this.$el.html(this.template.render(data, directives))
			return this;
		},
		initialize: function() {
			this.template = this.templateBase.clone();
			this.customers = new CustomerCollection();
			this.customers.on('add', this.addOne, this);
			this.customers.on('reset', this.addAll, this);
			this.customers.fetch();
		},
		addNewCustomer: function() {
			this.customers.create({
				suffix: this.$('.new-customer .suffixes').val(),
				name: this.$('.new-customer .name').val(),
				email: this.$('.new-customer .email').val(),
				phone: this.$('.new-customer .phone').val()
			});

			return false;
		},
		addOne: function(model) {
			var view = new CustomerRowView({
				model: model
			});
			this.$('.customers').append(view.render().el);
		},
		addAll: function() {
			this.customers.forEach(this.addOne);
		}
	});

	//Kickstart
	var app = new CustomersView();
	app.render();


});