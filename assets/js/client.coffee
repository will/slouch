console.log 'hi'

Todo = Backbone.Model.extend
  defaults: ->
    desc: 'empty hope...'
    date: new Date()
    name: 'will'

  initialize: ->
    @set(desc: @defaults.desc) unless @get('desc')

  toggle: ->
    @save(done: !@get('done'))

  clear: ->
    @destroy()

  isToday: ->
    @get('date').getDate() == (new Date).getDate()

TodoList = Backbone.Collection.extend
  model: Todo

  url: 'list.json'

Todos = new TodoList

TodoView = Backbone.View.extend
  tagName: 'li'

  template: _.template($('#item-template').html())

  events:
    'dblclick .view': 'edit'
    'click a.destroy': 'clear'
    'keypress .edit': 'updateOnEnter'
    'blur .edit': 'close'

  initialize: ->
    @model.bind('change', @render, this)
    @model.bind('destroy', @remove, this)

  render: ->
    @$el.html(@template(@model.toJSON()))
    @input = @$('.edit')
    this

  edit: ->
    @$el.addClass 'editing'
    @input.focus()

  close: ->
    value = @input.val()
    @clear() unless value
    @model.save desc: value
    @$el.removeClass 'editing'

  updateOnEnter: (e) ->
    @close() if e.keyCode == 13

  clear: ->
    @model.clear()

AppView = Backbone.View.extend
  el: $('#todoapp')

  events:
    'keypress #new-todo': 'createOnEnter'

  initialize: ->
    @input = @$('#new-todo')
    @allCheckbox = @$('#toggle-all')[0]

    Todos.bind('add', @addOne, @)
    Todos.bind('reset', @addAll, @)
    Todos.bind('all', @render, @)

    @footer = @$('footer')
    @main = @$('#main')

    Todos.fetch()
    Todos.create desc: 'a thing yesterday', date: new Date(2012,9,2)
    Todos.create desc: 'something else yesterday', date: new Date(2012,9,2)

  render: ->
    #if (Todos.length)
       @main.show()
       @footer.show()
    #else
    #  @main.hide()
    #  @footer.hide()

  addOne: (todo) ->
    if todo.isToday()
      el = "#todo-list-today"
    else
      el = "#todo-list-old"
    view = new TodoView(model: todo)
    @$(el).append(view.render().el)

  addAll: ->
    Todos.each(@addOne)

  createOnEnter: (e) ->
    return unless e.keyCode == 13
    return unless @input.val()

    Todos.create desc: @input.val()

App = new AppView

window.app = App
window.Todos = Todos
