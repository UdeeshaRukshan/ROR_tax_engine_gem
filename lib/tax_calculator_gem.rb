# frozen_string_literal: true

require_relative "tax_engine/version"
require_relative "tax_engine/errors"
require_relative "tax_engine/configuration"
require_relative "tax_engine/cache"
require_relative "tax_engine/api_client"
require_relative "tax_engine/calculator"

module TaxCalculatorGem
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
      configuration.validate!
      reset_cache!
    end

    def cache
      @cache ||= Cache.new(configuration)
    end

    def reset_cache!
      @cache = nil
    end

    def calculate(price:, location:, manual_rate: nil, category: nil)
      Calculator.calculate(price: price, location: location, manual_rate: manual_rate, category: category)
    end

    def total_price(price:, location:, manual_rate: nil, category: nil)
      Calculator.total_price(price: price, location: location, manual_rate: manual_rate, category: category)
    end

    def calculate_for_items(items:, location:)
      Calculator.calculate_for_items(items: items, location: location)
    end
  end
end