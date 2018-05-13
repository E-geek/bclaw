{ CSEmitter, CSEvent } = require 'cstd'

{ User } = require './user'

{ Area } = require './area'

log = console.log.bind console

lid = 1

class Arbiter extends CSEmitter

  id: -1

  user: null

  reputation: 0

  languages: null

  quantity: 0

  voted: no

  participationFee: 0

  disputeFee: 0

  constructor: (@user, areaName) ->
    @id = lid++
    @reputation = @user.reputation.arbiter
    @languages = @user.languages.filter (v) -> v.quantity >= 0.5
    @quantity = @user.status[areaName].quantity
    return

  getQuantity: ->
    return @reputation * @quantity

  vote: (vote, variant) ->
    return @

  addVariant: (vote, variant) ->
    return @

  removeVariant: (vote, variant) ->
    return @

  getChainId: ->
    return "A.#{@id}"

module.exports = { Arbiter }