console.log 'hi'

Photo = Backbone.Model.extend
  defaults:
    src: 'what.jpg'
    caption: 'a default image'
    viewed: false
    coordinates: [0,0]

  initialize: ->
    @this.on("change:src", ->
      src = @get("src")
      console.log 'Image src updated to ' + src)

  changeSrc: (source) -> @set src: source

# PhotoGallery = Backbone.Collection.extend
#   model: Photo
#
#   viewed: ->
#     @.filter (photo) -> photo.get('viewed')
#
#   unviewed: ->
#     @.wihtout.apply(this, this.viewed())
#
#
# buildPhotoView = (photoModel, photoController) ->
#   base    = document.createElement('div')
#   photoEl = document.createElement('div')
#
#   base.appendChild(photoEl)
#
#   render = ->
#     photoEl.innerHTML = _.template('photoTemplate', src: photoModel.getSrc())
#
#   photoModel.addSubscriber render
#
#   photoEl.addEventListener('click', ->
#     photoController.handleEvent('click', photoModel))
#
#   show = ->
#     photoEl.style.display = ''
#
#   hide = ->
#     photoEl.style.display = 'none'
#
#   showView: show, hideView: hide
#
#
# PhotoRouter = Backbone.Router.extend
#   routes: "photos/:id": "route"
#
#   route: (id) ->
#     item = photoCollection.get(id)
#     view = new PhotoView model: item
#
#     something.html( view.render().el )
#
#
# PhotoView = Backbone.View.extend
#   tagName: 'li'
#
#   template: _.template($('#photo-template').html())
#
#   events: "click img" : "toggleViewed"
#
#   initialize: ->
#     _.bindAll(this, 'render')
#     @model.on('change', @render)
#     @model.on('destory', @remove)
#
#     render: ->
#       @$el.html(@template(@model.toJSON()))
#
#     toggleViewed: -> @model.viewed()
