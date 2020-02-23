class LpBTradeIssuerService < LpTradeIssuerFixServiceBase
  def initialize
    @lp = LIQUIDITY_PROVIDER_B
    super()
  end

  # FIX is a protocol used to execute market orders against a Liquidity Provider
  def issue_fix_market_trade(**params)
    if fix_service_health_check_ok?(@lp)
      begin
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

        response = wait_for_fix_response(params[:order_id], @lp)
        handle_fix_trade_confirmation(response)

      rescue => error
        { success: false, error: error }
      end
    else
      { success: false, error: FixServiceDown }
    end
  end
end
