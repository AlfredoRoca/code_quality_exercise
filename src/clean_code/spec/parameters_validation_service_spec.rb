require_relative '../parameters_validation_service.rb'
require 'date'

RSpec.shared_examples :valid_parameters do
  it 'returns true' do
    expect(described_class.new(params).valid?).to be true
  end
end

RSpec.shared_examples :invalid_parameters do |param, new_value|
  it 'returns false' do
    params[param] = new_value if param

    expect(described_class.new(params).valid?).to be false
  end
end

RSpec.describe ParametersValidationService do

  describe '#param_numeric_is_number?(value)' do
    it 'returns true when value is kind of a number' do
      [-1, 0, 1, '123', '-1.5', '1.5'].each do |number|
        expect(described_class.new.param_numeric_is_number?(number)).to be true
      end
    end

    it 'returns false when value is a string containing not a number' do
      %w[qwe 23w 34qw45 po212].each do |string|
        expect(described_class.new.param_numeric_is_number?(string)).to be false
      end
    end
  end

  describe '#param_date_is_in_the_future?(value)' do
    it 'returns true when value is kind of a date in the future' do
      ['2/1/2030', '2030-07-25'].each do |date|
        expect(described_class.new.param_date_is_in_the_future?(date)).to be true
      end
    end

    it 'returns false when value is kind of a date in the past' do
      ['2/1/2020', '2019-07-25'].each do |date|
        expect(described_class.new.param_date_is_in_the_future?(date)).to be false
      end
    end
  end

  describe '#valid?' do
    let(:params) {
      {
        side: 'buy',
        amount: 1_000_000,
        currency: 'USD',
        counter_currency: 'EUR',
        date: (Date.today + 5).to_s,
        price: 1.1345,
        order_id: 'X-A213FFL'
      }
    }

    context 'with good params, order executable' do
      it_behaves_like :valid_parameters
    end

    context do
      context 'if some missing parameter' do
        let(:params) {
          {
            amount: 1_000_000,
            currency: 'USD',
            counter_currency: 'EUR',
            date: (Date.today + 5).to_s,
            price: 1.1345,
            order_id: 'X-A213FFL'
          }
        }

        it_behaves_like :invalid_parameters
      end

      context 'if some parameter is nil' do
        it_behaves_like :invalid_parameters, :currency, nil
      end

      context 'if some parameter is an empty string' do
        it_behaves_like :invalid_parameters, :order_id, ''
      end

      context 'if value date is in the past' do
        it_behaves_like :invalid_parameters, :date, '1970-01-01'
      end

      context 'if amount is negative or 0' do
        it_behaves_like :invalid_parameters, :amount, -1
        it_behaves_like :invalid_parameters, :amount, 0
      end

      context 'if amount is not a number' do
        it_behaves_like :invalid_parameters, :amount, 'qwe'
      end

      context 'if exchange rate is negative or 0' do
        it_behaves_like :invalid_parameters, :price, -1
        it_behaves_like :invalid_parameters, :price, 0
      end

      context 'if exchange rate is not a number' do
        it_behaves_like :invalid_parameters, :price, 'qwe'
      end
    end
  end
end
