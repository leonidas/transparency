class window.Todos extends Spine.Controller
	ENTER_KEY = 13

	elements:
		'.edit': 'editElem'

	events:
		'click    .destroy': 'destroy'
		'click    .toggle':  'toggleStatus'
		'dblclick .view':    'edit'
		'keyup    .edit':    'finishEditOnEnter'
		'blur     .edit':    'finishEdit'

	constructor: ->
		super
		@todo.bind 'update', @render
		@todo.bind 'destroy', @release

	render: =>
		console.log "render #{@todo.title}"
		@el.render @todo,
			toggle: checked: -> if @completed then "checked"
		@refreshElements()
		@el.addClass 'completed' if @todo.completed
		@

	destroy: ->
		@todo.destroy()

	toggleStatus: ->
		@todo.updateAttribute 'completed', !@todo.completed

	edit: ->
		@el.addClass 'editing'
		@editElem.focus()

	finishEdit: ->
		@el.removeClass 'editing'
		val = $.trim @editElem.val()
		if val then @todo.updateAttribute('title', val) else @destroy()

	finishEditOnEnter: (e) ->
		@finishEdit() if e.which is ENTER_KEY
