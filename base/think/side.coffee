{ CSEmitter, CSEvent } = require 'cstd'

{ User } = require './user'

log = console.log.bind console

lid = 1

class Side extends CSEmitter

  users: null

  funds: null

  # users|funds
  type: ''

  constructor: (@type, members) ->
    @[@type] = (members or []).slice 0
    return

  addMember: (member) ->
    @[@type].push member
    return @

  reservePay: ->

  reservePayArbiters: ->

  approveRequest: ->

  approve: ->

  pay: ->

  finishArbiters: ->

module.exports = { Side }
