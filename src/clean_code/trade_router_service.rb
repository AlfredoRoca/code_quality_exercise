class TradeRouterService
  LIQUIDITY_PROVIDER_A = "lpA"
  LIQUIDITY_PROVIDER_B = "lpB"
  LIQUIDITY_PROVIDER_C = "lpC"

  def initialize(amount, currency)
    @usd_amount = amount_in_usd(amount, currency)
    @lp = lp
  end

  def lp
    case @usd_amount
    when 0..10_000
      LIQUIDITY_PROVIDER_C
    when 10_000..100_000
      LIQUIDITY_PROVIDER_B
    else
      LIQUIDITY_PROVIDER_A
    end
  end

  def trade_issuer
    case @lp
    when LIQUIDITY_PROVIDER_A
      TradeIssuerFixService.new(LIQUIDITY_PROVIDER_A)
    when LIQUIDITY_PROVIDER_B
      TradeIssuerFixService.new(LIQUIDITY_PROVIDER_B)
    when LIQUIDITY_PROVIDER_C
      TradeIssuerHttpService.new(LIQUIDITY_PROVIDER_C)
    else
      raise "unknown liquidity provider"
    end
  end

  def amount_in_usd(amount, currency)
    # it would return the integer amount in USD
  end
end