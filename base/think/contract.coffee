{ Request } = require './request'

# after approve Request by all sides req convert to contract
class Contract extends Request

  @transaction: null

  stepCounter: 0

  constructor: (request, @transaction) ->
    super request.toJSON()
    if request.about.steps?.length > 0
      @steps = request.about.steps
    @transaction.emit 'fixed'
    for side in @sides
      for member in side[side.type]
        if member.type is 'payer'
          member.payFix()
        else if member.type is 'fund'
          member.registerContract @
        else # not payer
          member.compensationFix()
    return

  # for approve not-payment action and not inner system send request from `side` to other sides
  approveRequestSide: (side, message) ->

  # for inner-system action approve automatic without req
  approveSide: (side) ->

  # when one of side try escape from contract
  abort: (side, message) ->

  # one of side can do not approve request
  rejectApprove: (rejectSide, requestSide, message) ->

  # initiator is `member` (not side)
  startDispute: (initiator, message) ->

module.exports = { Contract }