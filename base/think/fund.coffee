{ CSEmitter, CSEvent } = require 'cstd'

class Fund extends CSEmitter

  arbiters: null

  owner: null

  transactions: null

  constructor: (@arbiters, @owner) ->
    @transactions = []
    super ['dispute', 'dissolution']
    return

  addTransaction: (transaction) ->
    @transactions.push transaction
    return

module.exports = { Fund }
