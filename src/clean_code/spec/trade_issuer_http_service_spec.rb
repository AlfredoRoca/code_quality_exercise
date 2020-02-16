require_relative "../trade_issuer_http_service.rb"
require_relative "../lp_c_trade_issuer_service.rb"
require 'pry'

RSpec.describe TradeIssuerHttpService do
  describe '#issue' do
    let(:currency) { 'USD' }
    let(:issuer_url) { 'http://lp_c_host/trade' }
    let(:issuer_response) { instance_double(HTTParty::Response, body: issuer_response_body) }
    let(:issuer_response_body) { 'response_body' }
    subject { described_class.new(LIQUIDITY_PROVIDER_C).issuer }

    before do
      allow(HTTParty).to receive(:post).and_return(issuer_response)
    end

    it 'calls the REST market trade issuer' do
      expect(HTTParty).to receive(:post).with(issuer_url)

      binding.pry

      subject.issue('side', 'size', 'currency', 'counter_currency', 'date', 'price', 'order_id')
    end
  end
end
