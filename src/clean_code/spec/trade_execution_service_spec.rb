require_relative "../lp_trade_issuer_fix_service_base.rb"
require_relative "../lp_a_trade_issuer_service.rb"
require_relative "../lp_b_trade_issuer_service.rb"
require_relative "../lp_c_trade_issuer_service.rb"
require_relative "../trade_execution_service.rb"
require 'mock_redis'

RSpec.describe TradeExecutionService do
  describe '#execute_order' do
    context 'when Redis or the Fix Service are down' do
      before do
        allow(Redis).to receive(:new) { MockRedis.new }
        allow_any_instance_of(LpTradeIssuerFixServiceBase).to receive(:fix_service_health_check_ok?) { false }
      end

      it 'fails' do
        payload = {
          side: 'buy',
          amount: 10_000_000,
          currency: 'USD',
          counter_currency: 'EUR',
          date: '11/12/2030',
          price: '1.1345',
          order_id: 'X-A213FFL'
        }

        expect(described_class.new.execute_order(payload)).to include(success: false, error: FixServiceDown)
      end
    end

    context 'when Redis and the Fix Service are up and running' do
      before do
        allow(Redis).to receive(:new) { MockRedis.new }
        allow_any_instance_of(LpTradeIssuerFixServiceBase).to receive(:fix_service_health_check_ok?) { true }
      end

      it 'fails if called with invalid parameters' do
        expect(described_class.new.execute_order({ dummy: 'dummy' })).to include(success: false)
      end

      it 'succeeds with the proper params' do
        payload = {
          side: 'buy',
          amount: 10_000_000,
          currency: 'USD',
          counter_currency: 'EUR',
          date: '11/12/2030',
          price: '1.1345',
          order_id: 'X-A213FFL'
        }

        expect(described_class.new.execute_order(payload)).to include(success: true)
      end
    end
  end
end
