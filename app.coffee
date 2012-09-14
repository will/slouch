express = require('express')
config = require('./config')
uuid = require('node-uuid')
app = express.createServer()
_ = require('underscore')
pg = require('pg').native
JsonStore = require('./json_store')

db = new pg.Client(config.database_url)
db.connect()

jsore = new JsonStore(db, 'hopes')

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

app.get '/list', (request, response) ->
  jsore.getAllByUserId request.user?.google?.id, (err, hopes) ->
    response.send( JSON.stringify(hopes) )

app.post '/list', (request, response) ->
  request.body.user_id = request.user.google.id
  jsore.create request.body, (err, hope) ->
    response.send JSON.stringify(err || hope)

app.get '/list/:id', (request, response) ->
  jsore.get request.params.id, (err, hope) ->
    response.send JSON.stringify(err || hope)

app.put '/list/:id', (request, response) ->
  jsore.update request.body, (err, hope) ->
    response.send JSON.stringify(err || hope)

app.delete '/list/:id', (request, response) ->
  jsore.destroy request.params.id, (err) ->
    response.send JSON.stringify(err || 'ok')

console.log("port: #{config.port}")
app.listen config.port

