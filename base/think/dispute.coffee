{ CSEmitter, CSEvent } = require 'cstd'

log = console.log.bind console

lid = 1

class Dispute extends CSEmitter

  id: -1

  variants: null

  message: ''

  arbiters: null

  schema: ''

  _countVotes: 0

  constructor: (@message, @arbiters, @schema) ->
    @variants = []

  resolve: ->

  addVariant: (variant) ->
    do @dropCounters
    @variants[variant] = [0, 0]
    @emit 'variants:change'
    return @

  dropCounters: ->
    for variant of @variants
      @variants[variant] = [0, 0]
    @_countVotes = 0
    for arbiter in @arbiters
      arbiter.voted = no
    return @

  vote: (arbiter, variant) ->
    if @arbiters.voted
      return @
    @arbiters.voted = yes
    chose = @variants[variant]
    chose[0]++
    chose[1] += arbiter.getQuantity()
    @_countVotes++
    return @

  validate: ->
    # checkSchema
    if @_countVotes isnt @arbiters.length
      return no
    return yes

module.exports = { Dispute }
