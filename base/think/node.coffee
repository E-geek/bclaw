{ CSEmitter, CSEvent, List, CSObject } = require 'cstd'

lid = 1

class Block extends CSObject

  id: -1

  action: null

  owner: null

  target: null

  sign: null

  constructor: ({ @action, @owner, @target, @sign }) ->
    if @action is 'user.create' and @target.id is 1 and lid is 1
      @id = lid++
      return
    if @sign isnt @owner.sign
      throw new Error "every block must have sign of owner"
    @id = lid++
    return

class Node extends CSEmitter

  chain: null

  funds: null

  constructor: (chain) ->
    if chain?
      @chain = chain
    else
      @chain = new List
    @funds = {}

  push: (opts) ->
    block = new Block opts
    unless opts.action?
      throw new Error "name not set"
    @chain.pushBack block
    return @

  addFunds: (name, fund) ->
    @funds[name] = fund
    return @

module.exports = { Node }