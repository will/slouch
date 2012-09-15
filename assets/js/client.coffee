checkModel = (model) ->
  return 'date not set' unless model.date
  return 'description missing' unless model.desc
  return 'description too short' if model.desc.length < 5
  return 'description too long'  if model.desc.length > 100
  return 'bump count not positive' unless model.bumpCount >= 0

Hope = Backbone.Model.extend
  defaults: ->
    desc: 'empty hope...'
    date: new Date()
    bumpCount: 0

  initialize: ->
    @set(desc: @defaults.desc) unless @get('desc')
    @on('error', (model, err) -> console.log(err))

  validate: (attrs) ->
    checkModel(attrs)

  toggle: ->
    @save(done: !@get('done'))

  clear: ->
    @destroy()

  isToday: ->
    @get('date').getDate() == (new Date).getDate()

HopeList = Backbone.Collection.extend
  model: Hope

  url: 'list'

  comparator: (a) ->
    a.get 'date'

Hopes = new HopeList

HopeView = Backbone.View.extend
  tagName: 'li'

  template: _.template($('#item-template').html())

  events:
    'dblclick .view': 'edit'
    'click a.destroy': 'clear'
    'click a.bump': 'bump'
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

  bump: ->
    @model.set('bumpCount', @model.get('bumpCount') + 1)
    @model.save()

  clear: ->
    @model.clear()

AppView = Backbone.View.extend
  el: $('#hopeapp')

  events:
    'keypress #new-hope': 'createOnEnter'

  initialize: ->
    @input = @$('#new-hope')
    @allCheckbox = @$('#toggle-all')[0]

    Hopes.bind('add', @addOne, @)
    Hopes.bind('reset', @addAll, @)
    Hopes.bind('all', @render, @)

    @footer = @$('footer')
    @main = @$('#main')

    Hopes.fetch()

  render: ->
    @main.show()
    @footer.show()

  addOne: (hope) ->
    el = "#hope-list"
    view = new HopeView(model: hope)
    @$(el).append(view.render().el)

  addAll: ->
    Hopes.each(@addOne)

  createOnEnter: (e) ->
    $('#error').text( '' )
    return unless e.keyCode == 13
    return unless @input.val()

    Hopes.create {desc: @input.val()},
      error: (model, error) ->
        $('#error').text( error )
        console.log "error here is " + error

App = new AppView

window.app = App
window.hopes = Hopes
