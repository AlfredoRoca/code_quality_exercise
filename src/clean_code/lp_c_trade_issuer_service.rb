require 'httparty'

class LpCTradeIssuerService
  def initialize
    @lp = LIQUIDITY_PROVIDER_C
  end

  def issue(**params)
    issue_rest_market_trade(params)
  end

  def issue_rest_market_trade(**params)
    payload = {
      order_type: 'market',
      side: params[:side],
      order_qty: params[:amount],
      ccy1: params[:currency],
      ccy2: params[:counter_currency],
      value_date: params[:date],
      price: params[:price],
      order_id: params[:order_id]
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
