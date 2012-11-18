$(function() {
  var CustomersView, CustomerRowView, CustomerModel, CustomerCollection;

  CustomerModel = Backbone.Model.extend({});

  CustomerCollection = Backbone.Collection.extend({
    model: CustomerModel,
    url: 'customers.json'
  });

  CustomersView = Backbone.View.extend({
    events: {
      'submit .new-customer': 'addCustomer',
      'click .delete': 'deleteCustomer'
    },

    el: $('#application'),

    render: function() {
      this.$('.customers').render(this.customers.toJSON(), {
        delete: {
          index: function(params) { return params.index; }
        }
      });

      return this;
    },

    initialize: function() {
      this.customers = new CustomerCollection();
      this.customers.on('add', this.render, this);
      this.customers.on('reset', this.render, this);
      this.customers.on('destroy', this.render, this);
      this.customers.fetch();
    },

    addCustomer: function(event) {
      event.preventDefault();
      this.customers.create({
        suffix: this.$('.new-customer .suffixes').val(),
        name:   this.$('.new-customer .name').val(),
        email:  this.$('.new-customer .email').val(),
        phone:  this.$('.new-customer .phone').val()
      });
    },

    deleteCustomer: function(event) {
      event.preventDefault();
      this.customers.at(event.target.getAttribute('index')).destroy();
    }
  });

  //Kickstart
  var app = new CustomersView();
  app.render();
});
