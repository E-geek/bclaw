{ CSEmitter, CSEvent } = require 'cstd'

{ Contract } = require './contract'

log = console.log.bind console

lid = 1

node = null

class Transaction extends CSEmitter

  id: -1

  request: null

  contract: null

  # array<Arbiter>
  arbiters: null

  # empty, request, approve, fixed[, dispute], done[, rollback]
  status: ''

  dispute: null

  emit: -> super

  constructor: (initial) ->
    @id = lid++
    @arbiters = []
    @status = 'empty'
    node.push
      action: 'transaction.new'
      target: @
      owner: initial
      sign: initial.sign
    super ['fixed', 'fixing:error']

  setRequest: (request) ->
    if @status not in ['empty', 'request']
      return new Error "set request after save contract impossible"
    @status = 'request'
    @request = request
    node.push
      action: 'transaction:request'
      target: @
      owner: request.creator
      sign: request.creator.sign
    return @

  approveRequest: (owner) ->
    if @status not in ['empty', 'request']
      return new Error "double approve is impossible"
    @status = 'approved'
    @contract = new Contract @request, @
    node.push
      action: 'transaction:request:approve'
      target: @
      owner: owner
      sign: owner.sign
    return @

  addArbiter: (arbiter) ->
    if @status not in ['approved', 'fixed', 'dispute']
      return new Error "add arbiter can only after approve and before finish"
    if arbiter not in @arbiters
      @arbiters.push arbiter
      for side in @contract.sides
        side.reservePayArbiter arbiter
    return @

  resolveArbiter: (arbiter) ->
    index = @arbiters.indexOf arbiter
    if @status not in ['approved', 'fixed', 'dispute'] or index < 0
      return @
    @arbiters = @arbiters.filter (v) -> v isnt arbiter
    return @

  fixingTransaction: ->
    if @status isnt 'approved'
      return new Error "only approved can be fixed"
    @status = 'fixed'
    for side in @contract.sides
      result = side.reservePay @contract
      if result isnt side
        @emit new CSEvent "fixing:error", @, result
        do @initRollback
        break
    return @

  finish: ->
    if @status not in ['fixed', 'dispute', 'rollback']
      return new Error "finish only processed transaction"
    @status = 'finish'
    for side in @contract.sides
      side.finishArbiters @arbiters
    return @

  startDispute: (sideInitiator, message) ->
    if @status not 'fixed'
      return new Error "dispute can be open only on fixed transaction"
    @status = 'dispute'
    @dispute = new Dispute message, @arbiters, @contract.arbiterSchema
    return @

  initRollback: ->
    if @status in ['finish', 'dispute']
      return new Error "rollback after and and in dispute not allow"
    @status = 'rollback'
    for side in @contract.sides
      side.finishArbiters @arbiters
    return @

  getChainId: ->
    return "T.#{@id}"

  @registerNode: (n) -> node = n; return

module.exports = { Transaction }
