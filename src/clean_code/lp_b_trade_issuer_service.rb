class LpBTradeIssuerService < TradeIssuerFixService
  def issue(side, size, currency, counter_currency, date, price, order_id)
    issue_fix_market_trade(side, size, currency, counter_currency, date, price, order_id)
  end

  # FIX is a protocol used to execute market orders against a Liquidity Provider
  def issue_fix_market_trade(side, size, currency, counter_currency, date, price, order_id)
    check_fix_service_status(@lp)
    send_to_redis(
      :lp_wall_street_provider_queue, 
      'fix:executetrade',
      ordType: 'D',
      clOrdID: order_id, 
      side: side,
      orderQty: size,
      currency_1: currency,
      currency_2: counter_currency,
      futSettDate: date,
      price: price
    )

    response = wait_for_fix_response(order_id, @lp)
    handle_fix_trade_confirmation(response)
  end

end