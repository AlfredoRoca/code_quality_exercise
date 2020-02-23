class TradeRouterService
  LIQUIDITY_PROVIDER_A = 'lpA'
  LIQUIDITY_PROVIDER_B = 'lpB'
  LIQUIDITY_PROVIDER_C = 'lpC'

  def initialize(amount, currency, rate = 1)
    @amount = amount
    @currency = currency.upcase
    @rate = rate
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
    @currency == 'USD' ? @amount : @amount * @rate
  end
end
