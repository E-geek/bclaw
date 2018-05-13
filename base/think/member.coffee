{ CSEmitter, CSEvent } = require 'cstd'

class Member extends CSEmitter

  user: null

  guarantor: null

  type: ''

  bid: 0

  langs: null

  contract: null

  transaction: null

  constructor: ({ @user, @guarantor, @currencyName, @bid, @langs, @type }) ->

  compensationFix: ->

  registerContract: (@contract) ->

  payFix: ->

module.exports = { Member }
