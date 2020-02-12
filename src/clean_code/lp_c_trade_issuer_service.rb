class LpCTradeIssuerService < TradeIssuerHttpService
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
    response = self.class.post('http://lp_c_host/trade', body: json_payload).response
    if response.code.to_i == 200
      handle_rest_trade_confirmation(response)
    else
      raise 'REST order execution failed.'
    end
  end
end
