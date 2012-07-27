class window.Todos extends Spine.Controller
	ENTER_KEY = 13

	elements:
		'.edit': 'editElem'

	events:
		'click    .destroy': 'destroy'
		'click    .toggle':  'toggle'
		'dblclick .view':    'edit'
		'keyup    .edit':    'blurOnEnter'
		'blur     .edit':    'finishEdit'

	constructor: ->
		super
		@todo.bind 'change',  @render
		@todo.bind 'destroy', @release

	render: =>
		@el.render @todo,
			toggle: checked: (p) ->
				p.element.checked = @completed
				return

		@el.toggleClass 'completed', @todo.completed
		@refreshElements()
		@

	destroy: ->
		@todo.destroy()

	toggle: ->
		@todo.updateAttributes completed: !@todo.completed

	edit: ->
		@el.addClass 'editing'
		@editElem.focus()

	finishEdit: ->
		@el.removeClass 'editing'
		val = $.trim @editElem.val()
		if val then @todo.updateAttributes(title: val) else @todo.destroy()

	blurOnEnter: (e) ->
		if e.keyCode is ENTER_KEY then e.target.blur()
