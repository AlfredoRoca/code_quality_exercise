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

    it 'calls the service endpoint via HTTP POST request with good params' do
      expect(HTTParty).to receive(:post).with('http://lp_c_host/trade', body:  JSON.dump(payload)).once

      TradeExecutionService.new.execute_order(params)
    end

    it 'returns success false if the HTTP POST raises any error' do
      stub_request(:post, 'http://lp_c_host/trade').with(body: JSON.dump(payload)).to_raise(StandardError.new('error!'))

      response = LpCTradeIssuerService.new.issue(params)
      expect(response).to eq({ success: false, error: 'error!' })
    end
  end
end
