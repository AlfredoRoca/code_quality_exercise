class TradeIssuerHttpService
  require 'httparty'

  LIQUIDITY_PROVIDER_C = "lpC"

  # TradeIssuerHttpService.new(lp).issue(side, size, currency, counter_currency, date, price, order_id)

  def initialize(lp)
    @lp = lp
  end
  
  def issuer
    case @lp
    when LIQUIDITY_PROVIDER_C
      LpCTradeIssuerService
    end
  end

  def issue(side, size, currency, counter_currency, date, price, order_id)
    issuer.issue_rest_market_trade(side, size, currency, counter_currency, date, price, order_id)
  end

  def handle_rest_trade_confirmation(rest_trade_confirmation)
    # trade confirmation will be persisted in db
  end
end