module TaxCalculatorGem
  class ApiError < StandardError; end
  class InvalidLocationError < StandardError; end
  class CalculationError < StandardError; end
end