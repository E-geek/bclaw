{ CSEmitter, CSEvent } = require 'cstd'

{ User } = require './user'

log = console.log.bind console

lid = 1

class Request extends CSEmitter

  # (u)int id of request
  id: -1

  # Array<Side>
  sides: null

  # description in algo and human readability format + steps is exists
  about: null

  # format style: "(C < 10 && W > xy%) || -P <= z"
  # read as "if count of arbiters less then 10 vote valid when weight votes great then xy%
  #   else if count of arbiters great then 9 vote valid when maximum z arbiter chose not most popular variant"
  # where (for ex. "Ya" is most popular variant in vote)
  # + C is count of arbiters
  # + W is percentage of Sum(Pi*k1i*k2i) / Sum(Pall*k1all*k2all) (Pi -- count vote "Ya")
  # + P is point-voice max count chose "Ya" any variant (-P -- max not chose "Ya")
  arbiterSchema: ''

  # array<Area>
  areas: null

  # User
  creator: null

  # UserSign
  sign: null

  constructor: ({ @sides, @about, @arbiterSchema, @areas, @creator, id }) ->
    @id = id or lid++
    log "create request #{@id}"
    return

  sign: (user, sign) ->
    if @sign = User.signCheck sign
      log "sign request success"
      return @
    return new Error "sing not approved"

  getChainId: ->
    return "R.#{@id}"

  toJSON: ->
    if @sign
      return { @sides, @about, @arbiterSchema, @areas, @creator, @id }
    return {}

  @fromJSON: (objOrString) ->
    if typeof objOrString is 'string'
      obj = JSON.parse objOrString
    else
      obj = objOrString
    return new Request obj

module.exports = { Request }
