{ CSEmitter, CSEvent } = require 'cstd'

{ Transaction } = require './transaction'
{ Request } = require './request'
{ Contract } = require './contract'
{ Member } = require './member'
{ Side } = require './side'
{ Area } = require './area'

log = console.log.bind console

lid = 1

class Fix extends CSEmitter

  value: 0

  account: null

  id: -1

  transaction: null

  constructor: ({ @value, @transaction, @id = lid++ }) ->
    return

  setAccount: (account) ->
    if @account
      return new Error "account was set"
    @account = account
    return @

  getChainId: ->
    return "FIX.#{lid}"

class Account extends CSEmitter

  full: 0

  free: 0

  fixed: null

  guarantors: null

  user: null

  userType: ''

  fund: null

  currencyName: null

  instructions: null

  emit: ->
    {pot, evt} = super
    for fn in pot.o when typeof fn is 'function'
      fn.call @, evt
    pot.o = []
    pot.c = 0
    for fn in pot.h when typeof fn is 'function'
      fn.call @, evt
    return @

  constructor: ({ @user, @fund, @currencyName }) ->
    @guarantors = []
    @instructions = {}
    @fixed = new Map
    @userType = if @user? then 'user' else 'fund'
    super [
      'fixed', 'unfix'
      'payFromFixed:reject', 'payFromFixed:approve'
      'payGuarantor:reject', 'payGuarantor:approve'
      'guarantor:reject', 'guarantor:approve'
    ]
    this
      .on 'payFromFixed:approve', (evt) =>
        log "payFromFixed:approve evt #{evt.value}"
        @full += evt.value
        @free += evt.value
        return
      .on 'payGuarantor:approve', (evt) =>
        return
      .on 'fixed', (evt) =>
        log "fixed!!!"
        return
    return

  fix: (fix) ->
    if fix.value > @free
      return new Error "money not exists"
    fix.account = @
    @free -= fix.value
    @fixed.set fix.id, fix
    @emit new CSEvent 'fixed', @, fix.value
    return @

  unfix: (fix) ->
    unless @fixed.has fix.id
      return new Error "fix not registered"
    @free += fix.value
    @fixed.delete fix.id
    return @

  payFix: (fix, accountTo) ->
    unless @fixed.has fix.id
      accountTo.emit new CSEvent 'payFromFixed:reject', @, err = new Error "fix not registered"
      # global.consistentRegulator 'fix must be but missing', { fix }
      return err
    @full -= fix.value
    @fixed.delete fix.id
    accountTo.emit new CSEvent 'payFromFixed:approve', @, fix.value
    return @

  dedicateGuarantor: (guarantor, transaction, value) ->
    if guarantor not in @guarantors
      return new Error "guarantor subscribe this account"
    if guarantor.checkCanDedicate @, value
      assignment = guarantor.dedicate value, @
      @instructions[assignment.id] = assignment
      @emit new CSEvent 'guarantor:approve', @, value
    else
      @emit new CSEvent 'guarantor:reject', @, value
      return new Error "guarantor can't dedicate #{value}"
    return @

  resolveGuarantor: (assignment) ->
    { guarantor, id } = assignment
    if guarantor not in @guarantors
      return new Error "guarantor subscribe this account"
    delete @instructions[id]
    result = guarantor.resolve assignment
    if result isnt guarantor
      return result
    assignment.destructor()
    return @

  fuckupGuarantor: (assignment, accountTo) ->
    { guarantor } = assignment
    if guarantor not in @guarantors
      accountTo.emit new CSEvent 'payGuarantor:reject', @, err = new Error "fix not registered"
      # global.consistentRegulator 'try pay guarantor but error', { assignment }
      return err
    result = guarantor.pay assigment
    if result isnt guarantor
      accountTo.emit new CSEvent 'payGuarantor:reject', @, result
      # global.consistentRegulator 'pay from guarantor receive error', { assignment }
      return result
    delete @instructions[assignment.id]
    accountTo.emit new CSEvent 'payGuarantor:approve', @, assignment.value
    return @

  # Ahahah, this is MONSTER only for simple transfer money between accounts
  @transfer = (accountFrom, accountTo, volume) ->
    if volume > accountFrom.free
      return new Error "account haven't need volume free resources"
    memberFrom = new Member
      user: accountFrom.user or accountFrom.fund
      currencyName: accountFrom.currencyName
      bid: 1
      langs: ['en']
      type: 'payer'
    memberTo = new Member
      user: accountTo.user or accountTo.fund
      currencyName: accountTo.currencyName
      bid: 1
      langs: ['en']
      type: 'receiver'
    sideFrom = new Side accountFrom.userType+'s', [ memberFrom ]
    sideTo = new Side accountTo.userType+'s', [ memberTo ]
    tx = new Transaction accountFrom.user
    req = new Request
      sides: [sideFrom, sideTo]
      about:
        algo: null
        human: ''
      arbiterSchema: 'W == 100%'
      areas: [new Area 'trade', 1]
      creator: accountFrom.user
    tx
      .setRequest req
      .approveRequest(accountTo.user)
      .fixingTransaction()
    fix = new Fix { value: volume, tx }
    result = accountFrom.fix(fix).payFix(fix, accountTo)
    if result isnt accountFrom
      console.error result
      tx.initRollback()
    log "tx transfer complete"
    tx.finish()
    return

module.exports = { Fix, Account }