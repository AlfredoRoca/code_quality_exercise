class LpATradeIssuerService < LpTradeIssuerFixServiceBase
  def initialize
    @lp = LIQUIDITY_PROVIDER_A
    super()
  end

  # FIX is a protocol used to execute market orders against a Liquidity Provider
  def issue_fix_market_trade(**params)
    fix_service_health_check_ok?(lp)

    payload = {
      side: params[:side],
      orderQty: params[:amount],
      ccy1: params[:currency],
      ccy2: params[:counter_currency],
      value_date: params[:date],
      price: params[:price],
      clOrdID: params[:order_id]
    }

    send_to_redis(
      :lp_acme_provider_queue,
      'fix:order:execute',
      payload
    )

    response = wait_for_fix_response(order_id, lp)
    handle_fix_trade_confirmation(response)

    { success: true, error: nil }
  rescue FixServiceDown
    { success: false, error: 'FIX service down' }
  end
end
