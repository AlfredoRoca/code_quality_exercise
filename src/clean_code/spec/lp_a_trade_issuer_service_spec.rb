RSpec.describe LpATradeIssuerService do
  describe '#issue_fix_market_trade' do

    context 'when Redis and the Fix Service are up and running' do
      before do
        allow(Redis).to receive(:new) { MockRedis.new }
        allow_any_instance_of(LpTradeIssuerFixServiceBase).to receive(:fix_service_health_check_ok?) { true }
      end

      subject { described_class.new }
      let!(:params) {
        {
          side: 'buy',
          amount: 10_000_000,
          currency: 'USD',
          counter_currency: 'EUR',
          date: '11/12/2030',
          price: '1.1345',
          order_id: 'X-A213FFL'
        }
      }
      let!(:payload) {
        {
          side: params[:side],
          orderQty: params[:amount],
          ccy1: params[:currency],
          ccy2: params[:counter_currency],
          value_date: params[:date],
          price: params[:price],
          clOrdID: params[:order_id]
        }
      }


      it 'sends to Redis the data' do
        expect_any_instance_of(LpTradeIssuerFixServiceBase).to receive(:send_to_redis).with(:lp_acme_provider_queue, 'fix:order:execute', payload).once

        TradeExecutionService.new.execute_order(params)
      end
    end

    context 'when Redis or the Fix Service are down' do
      before do
        allow(Redis).to receive(:new) { MockRedis.new }
        allow_any_instance_of(LpTradeIssuerFixServiceBase).to receive(:fix_service_health_check_ok?) { false }
      end

      subject { described_class.new }
      let!(:params) {
        {
          side: 'buy',
          amount: 10_000_000,
          currency: 'USD',
          counter_currency: 'EUR',
          date: '11/12/2030',
          price: '1.1345',
          order_id: 'X-A213FFL'
        }
      }
      let!(:payload) {
        {
          side: params[:side],
          orderQty: params[:amount],
          ccy1: params[:currency],
          ccy2: params[:counter_currency],
          value_date: params[:date],
          price: params[:price],
          clOrdID: params[:order_id]
        }
      }


      it 'fails and do not send data to redis' do
        expect_any_instance_of(LpTradeIssuerFixServiceBase).to receive(:send_to_redis).never

        TradeExecutionService.new.execute_order(params)
      end
    end
  end
end
