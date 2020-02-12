class TradeExecutionService
  include HTTParty
  
  def initialize
  end

  def execute_order(side, size, currency, counter_currency, date, price, order_id)
    router = TradeRouterService.new(amount, currency)
    trade_issuer = router.trade_issuer
    trade_issuer.issue(side, size, currency, counter_currency, date, price, order_id)

  rescue => error
    File.open('path_to_log_file/errors.log', 'a') do |f|
      f.puts "Execution of #{order_id} failed."
    end
  end
end
