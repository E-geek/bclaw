{ Account, Fix } = require '../think/account'
{ Arbiter } = require '../think/arbiter'
{ Area } = require '../think/area'
{ Contract } = require '../think/contract'
{ Dispute } = require '../think/dispute'
{ Fund } = require '../think/fund'
{ Guarantor, Assignment } = require '../think/gurantor'
{ Member } = require '../think/member'
{ Node, Block } = require '../think/node'
{ Request } = require '../think/request'

{ Side } = require '../think/side'
{ Transaction } = require '../think/transaction'
{ User } = require '../think/user'

{ assert } = require 'chai'

log = console.log.bind console

CURRENCY_NAME = 'CN'

node = new Node

User.registerNode node
Transaction.registerNode node

user = new User
  name: 'law'
  login: '_l_'
  parent: 0
  sign: 'TRUST'

node.push
  action: 'user.create'
  owner: user
  target: user
  sign: 'TRUST'

user.accounts[CURRENCY_NAME] = new Account { user, currencyName: CURRENCY_NAME }

root = user
user.accounts[CURRENCY_NAME].full = 10000000
user.accounts[CURRENCY_NAME].free = 10000000
user = null

node.push
  action: 'user.account.add'
  owner: root
  target: root.accounts[CURRENCY_NAME]
  sign: 'TRUST'

users =
  a: User.createUser
    name: 'A'
    login: '_a'
    parent: root.id
    sign: 'a-sig-a'
    currencyName: CURRENCY_NAME
  b: User.createUser
    name: 'B'
    login: '_b'
    parent: root.id
    sign: 'b-sig-b'
    currencyName: CURRENCY_NAME
  ca: User.createUser
    name: 'CA'
    login: '_ca'
    parent: root.id
    sign: 'cont-ca'
    currencyName: CURRENCY_NAME
  cb: User.createUser
    name: 'CB'
    login: '_cb'
    parent: root.id
    sign: 'cont-cb'
    currencyName: CURRENCY_NAME

result = Account.transfer root.accounts[CURRENCY_NAME],
  users.a.accounts[CURRENCY_NAME], 100000

assert.equal users.a.accounts[CURRENCY_NAME].full, 100000
assert.equal users.a.accounts[CURRENCY_NAME].free, 100000
assert.equal root.accounts[CURRENCY_NAME].full, 10000000 - 100000
assert.equal root.accounts[CURRENCY_NAME].free, 10000000 - 100000

log "transfer 1 complete. Now user A have 100000"

result = Account.transfer root.accounts[CURRENCY_NAME],
  users.b.accounts[CURRENCY_NAME], 100000

assert.equal users.b.accounts[CURRENCY_NAME].full, 100000
assert.equal users.b.accounts[CURRENCY_NAME].free, 100000
assert.equal root.accounts[CURRENCY_NAME].full, 10000000 - 200000
assert.equal root.accounts[CURRENCY_NAME].free, 10000000 - 200000

log "transfer 2 complete. Now user B have 100000"


lawFund = new Fund [
  new Arbiter users.ca, 'trade'
  new Arbiter users.cb, 'trade'
], root
