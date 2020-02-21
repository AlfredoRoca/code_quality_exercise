class LpBTradeIssuerService < LpTradeIssuerFixServiceBase
  def initialize
    @lp = LIQUIDITY_PROVIDER_B
    super()
  end

  # FIX is a protocol used to execute market orders against a Liquidity Provider
  def issue_fix_market_trade(**params)
    if fix_service_health_check_ok?
      payload = {
        ordType: 'D',
        side: params[:side],
        orderQty: params[:amount],
        currency_1: params[:currency],
        currency_2: params[:counter_currency],
        futSettDate: params[:date],
        price: params[:price],
        clOrdID: params[:order_id]
      }

      send_to_redis(
        :lp_wall_street_provider_queue,
        'fix:executetrade',
        payload
      )

      response = wait_for_fix_response(order_id, lp)
      handle_fix_trade_confirmation(response)

      { success: true, error: nil }
    else
      { success: false, error: FixServiceDown }
    end
  end
  
  def fix_service_health_check_ok?
    redis_health_check_ok? && is_fix_service_alive?
  end

  def is_fix_service_alive?
    send_to_redis(
      :lp_wall_street_provider_queue,
      'fix:health_check'
    )
    



  end

end
