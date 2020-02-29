class TradeRouterService
  LIQUIDITY_PROVIDER_A = 'lpA'
  LIQUIDITY_PROVIDER_B = 'lpB'
  LIQUIDITY_PROVIDER_C = 'lpC'

  def initialize(**trade_spec)
    @amount = trade_spec[:amount].to_f
    @currency = trade_spec[:currency].upcase
    @counter_currency = trade_spec[:counter_currency].upcase
    @rate = trade_spec[:price].to_f
    @direction = trade_spec[:side].upcase
    @lp = lp
  end

  def lp
    case amount_in_usd
    when 0..9_999
      LIQUIDITY_PROVIDER_C
    when 10_000..99_999
      LIQUIDITY_PROVIDER_B
    when (100_000..)
      LIQUIDITY_PROVIDER_A
    else
      raise 'unknown liquidity provider'
    end
  end

  def trade_issuer
    case @lp
    when LIQUIDITY_PROVIDER_A
      LpATradeIssuerService
    when LIQUIDITY_PROVIDER_B
      LpBTradeIssuerService
    when LIQUIDITY_PROVIDER_C
      LpCTradeIssuerService
    else
      raise 'unknown liquidity provider'
    end
  end

  def amount_in_usd
    # for the sake of the scope of this exercise I'm assuming one of the currencies is in USD, so the conversion is direct (no need of using Money)
    ((@direction == 'BUY' && @currency == 'USD') || (@direction == 'SELL' && @counter_currency == 'USD')) ? @amount : @amount * @rate
  end
end
