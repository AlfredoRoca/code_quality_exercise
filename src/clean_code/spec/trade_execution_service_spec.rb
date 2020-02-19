require_relative '../trade_execution_service.rb'

RSpec.describe TradeExecutionService do
  describe '#execute_order' do
    it 'returns failure if called with invalid parameters' do
      expect(described_class.new.execute_order({ dummy: 'dummy' })).to include(success: false)
    end

    it 'returns failure if amount is ' do
      expect(described_class.new.execute_order({ dummy: 'dummy' })).to include(success: false)
    end
  end
end
