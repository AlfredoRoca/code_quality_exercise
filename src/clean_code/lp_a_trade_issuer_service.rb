class LpATradeIssuerService < TradeIssuerFixService
  def issue(side, size, currency, counter_currency, date, price, order_id)
    issue_fix_market_trade(side, size, currency, counter_currency, date, price, order_id)
  end

  # FIX is a protocol used to execute market orders against a Liquidity Provider
  def issue_fix_market_trade(side, size, currency, counter_currency, date, price, order_id)
    check_fix_service_status(@lp)
    send_to_redis(
      :lp_acme_provider_queue, 
      'fix:order:execute',
      clOrdID: order_id, 
      side: side, 
      orderQty: size, 
      ccy1: currency, 
      ccy2: counter_currency,
      value_date: date, 
      price: price
    )

    response = wait_for_fix_response(order_id, @lp)
    handle_fix_trade_confirmation(response)
  end
end