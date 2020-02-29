RSpec.describe TradeRouterService do
  describe '#amount_in_usd(order_spec)' do
    it 'returns the converted amount to USD if the spec is BUY USD WITH EUR' do
      trade_spec = {
        side: 'buy',
        amount: 10_000,
        currency: 'USD',
        counter_currency: 'EUR',
        date: '11/12/2030',
        price: '1.1345',
        order_id: 'X-A213FFL'
      }

      expect(described_class.new(trade_spec).amount_in_usd).to eq 10_000
    end

    it 'returns the converted amount to USD if the spec is BUY EUR WITH USD' do
      trade_spec = {
        side: 'buy',
        amount: 10_000,
        currency: 'EUR',
        counter_currency: 'USD',
        date: '11/12/2030',
        price: '1.1345',
        order_id: 'X-A213FFL'
      }

      expect(described_class.new(trade_spec).amount_in_usd).to eq 10_000 * 1.1345
    end

    it 'returns the converted amount to USD if the spec is SELL USD WITH EUR' do
      trade_spec = {
        side: 'sell',
        amount: 10_000,
        currency: 'USD',
        counter_currency: 'EUR',
        date: '11/12/2030',
        price: '1.1345',
        order_id: 'X-A213FFL'
      }

      expect(described_class.new(trade_spec).amount_in_usd).to eq 10_000 * 1.1345
    end

    it 'returns the converted amount to USD if the spec is SELL EUR WITH USD' do
      trade_spec = {
        side: 'sell',
        amount: 10_000,
        currency: 'EUR',
        counter_currency: 'USD',
        date: '11/12/2030',
        price: '1.1345',
        order_id: 'X-A213FFL'
      }

      expect(described_class.new(trade_spec).amount_in_usd).to eq 10_000
    end
  end

  describe '#lp' do
    let(:trade_spec) {
      {
        side: 'buy',
        amount: amount,
        currency: 'USD',
        counter_currency: 'EUR',
        date: '11/12/2030',
        price: '1.1345',
        order_id: 'X-A213FFL'
      }
    }

    shared_examples_for :lp do |amount, lp|
      let(:amount) { amount }
      let(:lp) { lp }

      it "returns the lp name #{lp}" do
        expect(described_class.new(trade_spec).lp).to eq lp
      end
    end

    context 'when amount is 0 USD' do
      it_behaves_like :lp, 0, LIQUIDITY_PROVIDER_C
    end

    context 'when amount is just less than 10K USD' do
      it_behaves_like :lp, 9_999, LIQUIDITY_PROVIDER_C
    end

    context 'when amount is between 0 and 9_999 USD' do
      it_behaves_like :lp, 5_000, LIQUIDITY_PROVIDER_C
    end

    context 'when amount is 10K USD' do
      it_behaves_like :lp, 10_000, LIQUIDITY_PROVIDER_B
    end

    context 'when amount is just less than 100K USD' do
      it_behaves_like :lp, 99_999, LIQUIDITY_PROVIDER_B
    end

    context 'when amount is between 10K and 100K USD' do
      it_behaves_like :lp, 50_000, LIQUIDITY_PROVIDER_B
    end

    context 'when amount is 100K USD' do
      it_behaves_like :lp, 100_000, LIQUIDITY_PROVIDER_A
    end

    context 'when amount is more than 100K USD' do
      it_behaves_like :lp, 100_001, LIQUIDITY_PROVIDER_A
    end

    context 'raises an error if amount is negative' do
      let(:trade_spec) {
        {
          side: 'buy',
          amount: -1,
          currency: 'USD',
          counter_currency: 'EUR',
          date: '11/12/2030',
          price: '1.1345',
          order_id: 'X-A213FFL'
        }
      }

      it '' do
        expect { described_class.new(trade_spec).lp }.to raise_error('unknown liquidity provider')
      end
    end
  end

  describe '#trade_issuer' do
    context 'when it is an lp' do

      let(:trade_spec) {
        {
          side: 'buy',
          amount: 0,
          currency: 'USD',
          counter_currency: 'EUR',
          date: '11/12/2030',
          price: '1.1345',
          order_id: 'X-A213FFL'
        }
      }

      shared_examples_for :trade_issuer do |lp, the_expected_issuer|
        let(:lp) { lp }

        it "returns the #{the_expected_issuer.to_s} that manages the lp #{lp}" do
          allow_any_instance_of(described_class).to receive(:lp) { lp }

          expect(described_class.new(trade_spec).trade_issuer).to be the_expected_issuer
        end
      end

      it_behaves_like :trade_issuer, LIQUIDITY_PROVIDER_A, LpATradeIssuerService
      it_behaves_like :trade_issuer, LIQUIDITY_PROVIDER_B, LpBTradeIssuerService
      it_behaves_like :trade_issuer, LIQUIDITY_PROVIDER_C, LpCTradeIssuerService

      it "raises an error if the lp has no service" do
        allow_any_instance_of(described_class).to receive(:lp) { 'unknown lp' }

        expect { described_class.new(trade_spec).trade_issuer }.to raise_error('unknown liquidity provider')
      end
    end
  end
end
