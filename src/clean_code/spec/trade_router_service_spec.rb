RSpec.describe TradeRouterService do

  describe '#amount_in_usd(amount, currency, rate)' do
    it 'returns the amount if the currency is USD' do
      expect(described_class.new(100, 'usd', 1.2).amount_in_usd).to eq 100
    end

    it 'returns the converted amount if the currency is not USD' do
      expect(described_class.new(100, 'eur', 1.2).amount_in_usd).to eq 120
    end
  end

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

    it 'raises an error if amount is negative' do
      expect { described_class.new(-1, currency).lp }.to raise_error('unknown liquidity provider')
    end
  end

  describe '#trade_issuer' do
    let(:currency) { 'USD' }

    shared_examples_for :trade_issuer do |amount, issuer_class, issuer_parent_class|
      let(:issuer) { described_class.new(amount, currency).trade_issuer }

      it 'returns the proper issuer', :aggregate_failures do
        expect(issuer).to eq issuer_class
        expect(issuer.superclass).to be issuer_parent_class
      end
    end

    it_behaves_like :trade_issuer, 10, LpCTradeIssuerService, Object
    it_behaves_like :trade_issuer, 50_000, LpBTradeIssuerService, LpTradeIssuerFixServiceBase
    it_behaves_like :trade_issuer, 250_000, LpATradeIssuerService, LpTradeIssuerFixServiceBase

    it 'raises an error for an unknown LP' do
      expect { described_class.new(-1, currency).trade_issuer }.to raise_error('unknown liquidity provider')
    end
  end
end
