console.log 'hi'

Todo = Backbone.Model.extend
  defaults: ->
    title: 'empty todo...'
    order: Todos.nextOrder()
    done: false

  initialize: ->
    @set(title: @defaults.title) unless @get('title')

  toggle: ->
    @save(done: !@get('done'))

  clear: ->
    @destroy()

TodoList = Backbone.Collection.extend
  model: Todo

  url: 'list.json'

  done: ->
    @filter( (todo) -> todo.get('done') )

  remaining: ->
    @without.apply(@, @done())

  nextOrder: ->
    return 1 unless @length
    @last().get('order') + 1

  comparator: (todo) ->
    todo.get('order')

Todos = new TodoList

TodoView = Backbone.View.extend
  tagName: 'li'

  template: _.template($('#item-template').html())

  events:
    'click .toggle': 'toggleDone'
    'dblclick .view': 'edit'
    'click a.destroy': 'clear'
    'keypress .edit': 'updateOnEnter'
    'blur .edit': 'close'

  initialize: ->
    @model.bind('change', @render, this)
    @model.bind('destroy', @remove, this)

  render: ->
    @$el.html(@template(@model.toJSON()))
    @$el.toggleClass('done', @model.get('done'))
    @input = @$('.edit')
    this

  toggleDone: ->
    @model.toggle()

  edit: ->
    @$el.addClass 'editing'
    @input.focus()

  close: ->
    value = @input.val()
    @clear() unless value
    @model.save title: value
    @$el.removeClass 'editing'

  updateOnEnter: (e) ->
    @close() if e.keyCode == 13

  clear: ->
    @model.clear()

AppView = Backbone.View.extend
  el: $('#todoapp')

  statsTemplate: _.template($('#stats-template').html())

  events:
    'keypress #new-todo': 'createOnEnter'
    'click #clear-completed': 'clearCompleted'
    'click #toggle-all': 'toggleAllComplete'

  initialize: ->
    @input = @$('#new-todo')
    @allCheckbox = @$('#toggle-all')[0]

    Todos.bind('add', @addOne, @)
    Todos.bind('reset', @addAll, @)
    Todos.bind('all', @render, @)

    @footer = @$('footer')
    @main = @$('#main')

    Todos.fetch()

  render: ->
    done = Todos.done().length
    remaining = Todos.remaining().length

    if (Todos.length)
       @main.show()
       @footer.show()
       @footer.html(@statsTemplate(done: done, remaining: remaining))
    else
      @main.hide()
      @footer.hide()

    @allCheckbox.checked = !remaining

  addOne: (todo) ->
    view = new TodoView(model: todo)
    @$("#todo-list").append(view.render().el)

  addAll: ->
    Todos.each(@addOne)

  createOnEnter: (e) ->
    return unless e.keyCode == 13
    return unless @input.val()

    Todos.create title: @input.val()

  clearCompleted: ->
    _.each( Todos.done(), (todo) -> todo.clear() )

  toggleAllComplete: ->
    done = @allCheckbox.checked
    Todos.each( (todo) -> todo.save 'done': done )

App = new AppView
