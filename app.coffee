express = require('express')
config = require('./config')
uuid = require('node-uuid')
app = express.createServer()
_ = require('underscore')

everyauth = require('everyauth')
everyauth.debug = true

usersByGoogleId = {}
usersById = {}
nextUserId = 0

addUser = (source, sourceUser) ->
  if arguments.length == 1
    user = sourceUser = source;
    user.id = ++nextUserId;
    return usersById[nextUserId] = user
  else
    user = usersById[++nextUserId] = {id: nextUserId};
    user[source] = sourceUser;
  return user

everyauth.everymodule
  .findUserById( (id, callback) ->
    callback(null, usersById[id])
  )
everyauth.google
  .appId(config.google.clientId)
  .appSecret(config.google.clientSecret)
  .scope('https://www.googleapis.com/auth/userinfo.profile')
  .findOrCreateUser( (sess, accessToken, extra, googleUser) ->
    googleUser.refreshToken = extra.refresh_token
    googleUser.expiresIn = extra.expires_in
    return usersByGoogleId[googleUser.id] || (usersByGoogleId[googleUser.id] = addUser('google', googleUser));
  )
  .redirectPath('/');

app.configure( ->
  app.set('views', __dirname + '/views')
  app.set('view engine', 'jade')
  app.use(express.logger())
  app.use(express.cookieParser())
  app.use(express.session({ secret: 'foobar' }))
  app.use(express.bodyParser())
  app.use(everyauth.middleware())
  app.use(require('connect-assets')() )
  app.use(express.methodOverride())
  app.use(app.router)
  app.use(express.static(__dirname + '/public'))
)

app.get '/', (request, response) ->
  response.render('index', user: request.user, title: 'hom3e')

list = [
  {
    id: uuid()
    desc: 'today'
    date: new Date()
    bumpCount: 0
  },
  {
    id: uuid()
    desc: 'old'
    date: new Date(2007,9,2)
    bumpCount: 2
  },
  {
    id: uuid()
    desc: 'also old'
    date: new Date(2010,9,2)
    bumpCount: 0
  }
]

app.get '/list', (request, response) ->
  response.send( JSON.stringify(list) )

app.post '/list', (request, response) ->
  item = request.body
  item.id = uuid()
  list.push item
  response.send( JSON.stringify(item) )

app.get '/list/:id', (request, response) ->
  item = _.find( list, (it) -> it.id == request.params.id )
  response.send JSON.stringify(item)

app.put '/list/:id', (request, response) ->
  list = _.reject( list, (it) -> it.id == request.params.id )
  item = request.body
  list.push item
  response.send JSON.stringify(item)

app.delete '/list/:id', (request, response) ->
  list = _.reject( list, (it) -> it.id == request.params.id )
  response.send 'ok'

console.log("port: #{config.port}")
app.listen config.port

