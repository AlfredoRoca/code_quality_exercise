class ParametersValidationService
  REQUIRED_PARAMETERS = %i[side amount currency counter_currency date price order_id]
  NUMERIC_FIELDS = %i[amount price]
  POSITIVE_FIELDS = %i[amount price]
  STRING_FIELDS = %i[side currency counter_currency order_id]
  DATE_FIELDS = %i[date]

  def initialize(**params)
    @params = params.compact
  end

  def valid?
    REQUIRED_PARAMETERS.all? do |param|
      required_param_is_present?(param) &&
      param_is_not_nil?(@params[param]) &&
      string_param_not_empty?(param) &&
      numeric_field_is_a_number?(param) &&
      numeric_positive_field_is_positive?(param) &&
      param_date_is_kind_of_a_date_in_the_future?(param)
    end
  end

  def required_param_is_present?(key)
    @params.include?(key)
  end

  def param_is_not_nil?(value)
    !value.nil?
  end

  def string_param_not_empty?(param)
    (!STRING_FIELDS.include?(param) || !@params[param].empty?)
  end

  def numeric_field_is_a_number?(param)
    (!NUMERIC_FIELDS.include?(param) || param_numeric_is_number?(@params[param]))
  end

  def param_numeric_is_number?(value)
    value = value.to_f if value.class == String && value =~ /^[+|-]?\d?\.?\d+$/
    [Integer, Float].include?(value.class)
  end

  def numeric_positive_field_is_positive?(param)
    (!POSITIVE_FIELDS.include?(param) || number_is_positive?(@params[param]))
  end

  def number_is_positive?(value)
    value = value.to_f if value.class == String && value =~ /^[+|-]?\d?\.?\d+$/
    value.positive?
  end

  def param_date_is_kind_of_a_date_in_the_future?(param)
    (!DATE_FIELDS.include?(param) || param_date_is_in_the_future?(@params[param]))
  end

  def param_date_is_in_the_future?(value)
    Date.parse(value) > Date.today
  rescue => e
    false
  end

  def invalid?
    !valid?
  end
end
