require_relative '../parameters_validation_service.rb'

RSpec.describe ParametersValidationService do
  describe '#valid?' do

    shared_examples_for :valid_parameters do |params|
      it 'returns true if all required parameters are present and not empty' do
        expect(described_class.new(params).valid?).to be true
      end
    end

    shared_examples_for :invalid_parameters do |params|
      it 'returns false' do
        expect(described_class.new(params).valid?).to be false
      end
    end

    context do
      full_params = {}
      described_class::REQUIRED_PARAMETERS.each { |param| full_params.merge!({ "#{param}": param.to_s }) }

      it_behaves_like :valid_parameters, full_params, "eooo"
    end

    context do
      context 'if some missing parameter' do
        params = {}
        [:amount].each { |param| params.merge!({ "#{param}": param.to_s }) }

        it_behaves_like :invalid_parameters, params
      end

      context 'if some parameter is nil' do
        params = {}
        described_class::REQUIRED_PARAMETERS.each { |param| params.merge!({ "#{param}": nil }) }

        it_behaves_like :invalid_parameters, params
      end

      context 'if some parameter is an empty string' do
        params = {}
        described_class::REQUIRED_PARAMETERS.each { |param| params.merge!({ "#{param}": '' }) }

        it_behaves_like :invalid_parameters, params
      end
    end
  end
end
