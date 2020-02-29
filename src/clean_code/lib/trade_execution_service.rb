require 'logger'
require_relative './errors.rb'
require_relative './trade_router_service.rb'
require_relative './parameters_validation_service.rb'

class TradeExecutionService
  def initialize
    @logger = Logger.new('app.log', 10, 10240000)
  end

  def execute_order(**trade_spec)
    return { success: false, error: 'Invalid parameters for an order' } if ParametersValidationService.new(trade_spec).invalid?

    trade_issuer = TradeRouterService.new(trade_spec).trade_issuer

    trade_issuer.new.issue(trade_spec)

  rescue => error
    @logger.error(error.message)
    { success: false, error: error.message }
  end
end
