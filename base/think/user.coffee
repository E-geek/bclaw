{ CSEmitter, CSEvent } = require 'cstd'

Account = null

log = console.log.bind console

lid = 1

node = null

class User extends CSEmitter

  id: -1

  name: ''

  login: ''

  parent: -1

  accounts: null

  data: null

  reputation: null

  languages: null

  status: null

  sign: null

  constructor: ({ @name, @login, @sign, @parent })->
    @id = lid++
    @accounts = []
    @data =
      open: {}
      private: {}
    @reputation =
      trade: 0
      arbiter: 0
    @languages = []
    @status =
      trade:
        status: 'none' # PHD, PHD Student, none
        quantity: 0
    ###
    @sign =
      private: null
      public: null
    ###

  @registerNode = (n) ->
    { Account } = require './account'
    node = n
    return

  @createUser = (opts) ->
    user = new User
      name: opts.name
      login: opts.login
      sign: opts.name + '||' + opts.sign
      parent: opts.parent
    node.push
      action: 'user.create'
      owner: opts.parent
      target: user
      sign: opts.parent.sign
    { currencyName } = opts
    user.accounts[currencyName] = new Account { user, currencyName }
    node.push
      action: 'user.account.add'
      owner: user
      target: user.accounts[currencyName]
      sign: user.sign
    return user


module.exports = { User }
