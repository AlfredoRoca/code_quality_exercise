require 'logger'
require_relative './errors.rb'
require_relative './trade_router_service.rb'

class TradeExecutionService
  def initialize
    logger = Logger.new('app.log', 10, 10240000)
  end

  def execute_order(**params)
    return { success: false, error: 'Invalid parameters for an order' } if ParametersValidationService.new(params).invalid?

    router = TradeRouterService.new(params[:amount], params[:currency])
    trade_issuer = router.trade_issuer
    trade_issuer.issue(params)

  rescue => error
    logger.error(error)
    { success: false, error: error.message }
  end
end
