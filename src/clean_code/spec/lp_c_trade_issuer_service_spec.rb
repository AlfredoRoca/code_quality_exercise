require_relative "../lp_trade_issuer_fix_service_base.rb"
require_relative "../lp_a_trade_issuer_service.rb"
require_relative "../lp_b_trade_issuer_service.rb"
require_relative "../lp_c_trade_issuer_service.rb"
require_relative "../trade_execution_service.rb"
require 'mock_redis'

RSpec.describe LpCTradeIssuerService do
  describe '#issue_fix_market_trade' do

    subject { described_class.new }
    let!(:params) {
      {
        side: 'buy',
        amount: 5_000,
        currency: 'USD',
        counter_currency: 'EUR',
        date: '11/12/2030',
        price: '1.1345',
        order_id: 'X-A213FFL'
      }
    }
    let(:payload) {
      {
        order_type: 'market',
        side: params[:side],
        order_qty: params[:amount],
        ccy1: params[:currency],
        ccy2: params[:counter_currency],
        value_date: params[:date],
        price: params[:price],
        order_id: params[:order_id]
      }
    }

    it 'fails and do not send data to redis' do
      expect(HTTParty).to receive(:post).with('http://lp_c_host/trade', body:  JSON.dump(payload)).once

      TradeExecutionService.new.execute_order(params)
    end
  end
end
