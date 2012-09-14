util = require('util')
pg = require('pg').native
db = new pg.Client('postgres:///slouch')
JsonStore = require('./json_store')
db.connect()

item = {athing: 3, otherthing: true, nested: {woah: [1,2,3,4,5]}}
js = new JsonStore(db, 'hopes')
js.create(item, (e,i) ->
  i.lolol = 'lolol'
  js.get(i.id, (a,b) -> console.log "get: #{util.inspect b}")
  js.update(i, (e, newi)->
    js.get(i.id, (a,b) ->
      console.log "get: #{util.inspect b}"
      js.destroy(i.id, ->
        js.get(i.id, (a,b) ->
          console.log util.inspect a
          db.end()
        )
      )
    )
  )
  console.log i.nested.woah[2]
  )

