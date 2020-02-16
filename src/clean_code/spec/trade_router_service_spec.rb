require_relative "../{*}.rb"

RSpec.describe TradeRouterService do
  LIQUIDITY_PROVIDER_A = "lpA"
  LIQUIDITY_PROVIDER_B = "lpB"
  LIQUIDITY_PROVIDER_C = "lpC"

  describe '#lp' do
    let(:currency) { 'USD' }

    it 'returns lpC when amount is less than 10K USD' do
      expect(described_class.new(0, currency).lp).to eq LIQUIDITY_PROVIDER_C
      expect(described_class.new(9_999, currency).lp).to eq LIQUIDITY_PROVIDER_C
    end

    it 'returns lpB when amount is between 10K and 100K USD' do
      expect(described_class.new(10_000, currency).lp).to eq LIQUIDITY_PROVIDER_B
      expect(described_class.new(99_999, currency).lp).to eq LIQUIDITY_PROVIDER_B
    end

    it 'returns lpA when amount is greater than 100K USD' do
      expect(described_class.new(100_000, currency).lp).to eq LIQUIDITY_PROVIDER_A
    end
  end

  describe '#issuer' do
    let(:currency) { 'USD' }

    it 'returns the issuer for lpA' do
      expect(described_class.new(10, currency).trade_issuer).to be_a LpCTradeIssuerService
    end
  end
end
