class LpATradeIssuerService < LpTradeIssuerFixServiceBase
  def initialize
    @lp = LIQUIDITY_PROVIDER_A
    super()
  end

  # FIX is a protocol used to execute market orders against a Liquidity Provider
  def issue_fix_market_trade(**params)
    check_fix_service_status(lp)

    side = params[:side]
    amount = params[:amount]
    currency = params[:currency]
    counter_currency = params[:counter_currency]
    date = params[:date]
    price = params[:price]
    order_id = params[:order_id]

    send_to_redis(
      :lp_acme_provider_queue,
      'fix:order:execute',
      clOrdID: order_id,
      side: side,
      orderQty: amount,
      ccy1: currency,
      ccy2: counter_currency,
      value_date: date,
      price: price
    )

    response = wait_for_fix_response(order_id, lp)
    handle_fix_trade_confirmation(response)

    { success: true, error: nil }
  rescue FixServiceDown
    { success: false, error: 'FIX service down' }
  end
end
