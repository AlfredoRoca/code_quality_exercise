require 'httparty'

class LpCTradeIssuerService
  def initialize
    @lp = LIQUIDITY_PROVIDER_C
  end

  def issue(side, size, currency, counter_currency, date, price, order_id)
    issue_rest_market_trade(side, size, currency, counter_currency, date, price, order_id)
  end

  def issue_rest_market_trade(side, size, currency, counter_currency, date, price, order_id)
    payload = {
      order_type: 'market',
      order_id: order_id,
      side: side,
      order_qty: size,
      ccy1: currency,
      ccy2: counter_currency,
      value_date: date,
      price: price
    }
    json_payload = JSON.dump(payload)
    response = HTTParty.post('http://lp_c_host/trade', body: json_payload)

    handle_rest_trade_confirmation(response.parsed_response)

    { success: response.success?, error: nil }

  rescue => error
    { success: false, error: error.message }
  end

  def handle_rest_trade_confirmation(rest_trade_confirmation)
    # trade confirmation will be persisted in db
  end
end
