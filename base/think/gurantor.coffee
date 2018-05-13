{ CSEmitter, CSEvent, CSObject } = require 'cstd'

lid = 1

class Assignment extends CSObject

  id: -1

  guarantor: null

  account: null

  value: 0

  constructor: (@value, @account, @guarantor) ->
    @id = lid++
    return

  destructor: ->
    @account = null
    @guarantor = null
    return @


class Guarantor extends CSEmitter

  id: -1

  currencyName: ''

  account: null

  user: null

  instructions: null

  limit: 0

  used: 0

  constructor: (@user, @currencyName) ->
    @id = lid++
    @instructions = new Map()
    @account = @user.accounts[@currencyName]
    return

  setLimit: (value) ->
    if @account.free < value
      return new Error "account can't dedicate limit"
    @limit = value
    return @

  dedicate: (value, account) ->
    if value > @limit - @used
      return new RangeError "free resources so small, can't dedicate"
    assignment = new Assignment value, account, @
    @instructions.set assignment.id, assignment
    @used += value
    return assignment

  resolve: (assignment) ->
    unless @instructions.has assignment.id
      return new Error "assignment not exists"
    @instructions.remove assignment.id
    @used -= assignment.value
    return @

  pay: (assignment, transaction) ->
    return new Error "method not support yet"

module.exports = { Guarantor, Assignment }
