require_relative "../lp_trade_issuer_fix_service_base.rb"
require_relative "../lp_a_trade_issuer_service.rb"
require_relative "../lp_b_trade_issuer_service.rb"
require_relative "../lp_c_trade_issuer_service.rb"
require_relative "../trade_router_service.rb"
require_relative "../trade_execution_service.rb"

RSpec.describe TradeRouterService do

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

  describe '#issuer' do
    let(:currency) { 'USD' }

    shared_examples_for :trade_issuer do |amount, issuer_class, issuer_parent_class|
      let(:issuer) { described_class.new(amount, currency).trade_issuer }

      it 'returns the proper issuer', :aggregate_failures do
        expect(issuer).to be_an_instance_of issuer_class
        expect(issuer.class.superclass).to be issuer_parent_class
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
