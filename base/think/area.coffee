{ CSObject } = require 'cstd'

log = console.log.bind console

lid = 1

class Area extends CSObject

  @list: [
    'any'
    'books'
    'computers'
  ]

  name: ''

  quantity: 0

  constructor: (@name, @quantity) ->
    log "area #{@name} created with qnt #{@quantity}"
    if @name not in Area.list
      Area.list.push @name
    return

module.exports = { Area }