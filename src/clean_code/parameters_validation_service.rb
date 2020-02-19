class ParametersValidationService
  REQUIRED_PARAMETERS = %i[side amount currency counter_currency date price order_id]

  def initialize(**params)
    @params = params.compact
  end

  def valid?
    REQUIRED_PARAMETERS.all? { |param| @params.include?(param) && !@params[param].empty? }
  end

  def invalid?
    !valid?
  end

end
