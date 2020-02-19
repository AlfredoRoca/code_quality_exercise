class TradeRouterService
  LIQUIDITY_PROVIDER_A = 'lpA'
  LIQUIDITY_PROVIDER_B = 'lpB'
  LIQUIDITY_PROVIDER_C = 'lpC'

  def initialize(amount, currency)
    @usd_amount = amount_in_usd(amount, currency)
    @lp = lp
  end

  def lp
    case @usd_amount
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
      LpATradeIssuerService.new
    when LIQUIDITY_PROVIDER_B
      LpBTradeIssuerService.new
    when LIQUIDITY_PROVIDER_C
      LpCTradeIssuerService.new
    else
      raise 'unknown liquidity provider'
    end
  end

  def amount_in_usd(amount, currency)
    # it would return the integer amount in USD
    amount
  end
end
