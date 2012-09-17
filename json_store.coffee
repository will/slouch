_ = require('underscore')
class JsonStore
  constructor: (db, tablename) ->
    @db = db
    @tablename = tablename

  getAllByUserId: (userId, callback) ->
    @db.query(
      "select * from #{@tablename} where json_select($1, data) = $2",
      ['.user_id', '"'+userId+'"'],
      (err, res) ->
        if err
          callback(err)
        else
          callback(null, _.map(res.rows, objFromRow))
    )

  getAll: (callback) ->
    @db.query(
      "select * from #{@tablename}",
      (err, res) ->
        if err
          callback(err)
        else
          callback(null, _.map(res.rows, objFromRow))
    )

  get: (id, callback) ->
    @db.query(
      "select * from #{@tablename} where id=$1",
      [id], (err,res) ->
        if err
          callback(err)
        else
          if res.rows.length == 1
            callback(null, objFromRow(res.rows[0]))
          else
            callback(null, null)
      )

  update: (obj, callback) ->
    [id, newObj] = idAndDataFromObj obj
    @db.query(
      "update #{@tablename} set data=$1 where id=$2 returning *",
      [JSON.stringify(newObj), id], (err,res) ->
        if err
          callback(err)
        else
          callback(null, objFromRow(res.rows[0]))
      )

  create: (obj, callback) ->
    @db.query(
      "insert into #{@tablename} (data) values ($1) returning *",
      [JSON.stringify(obj)], (err,res) ->
        if err
          callback(err)
        else
          callback(null, objFromRow(res.rows[0]))
      )

  destroy: (id, callback) ->
    @db.query("delete from #{@tablename} where id=$1", [id], (err,res) -> callback(err))

  objFromRow = (row) ->
    newObj = {}
    newObj.id = row.id
    for key, val of JSON.parse(row.data)
      newObj[key] = val
    return newObj

  idAndDataFromObj = (obj) ->
    newObj = {}
    id = obj.id
    for key, val of obj
      newObj[key] = val unless key == 'id'
    return [id, newObj]

module.exports = JsonStore
