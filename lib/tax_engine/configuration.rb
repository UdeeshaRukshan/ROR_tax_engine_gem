module TaxCalculatorGem
  class Configuration
    VALID_CACHE_STORES = %i[memory redis].freeze

    attr_accessor :api_key, :default_state, :cache_store, :cache_ttl, :redis_url

    def initialize
      @api_key       = nil
      @default_state = "WA"
      @cache_store   = :memory  # :memory or :redis
      @cache_ttl     = 3600     # seconds (1 hour)
      @redis_url     = "redis://localhost:6379/0"
    end

    def validate!
      unless VALID_CACHE_STORES.include?(@cache_store)
        raise ArgumentError, "Invalid cache_store '#{@cache_store}'. Must be one of: #{VALID_CACHE_STORES.join(', ')}"
      end
      unless @cache_ttl.is_a?(Integer) && @cache_ttl.positive?
        raise ArgumentError, "cache_ttl must be a positive integer (seconds)"
      end
      if @cache_store == :redis && (@redis_url.nil? || @redis_url.empty?)
        raise ArgumentError, "redis_url must be set when cache_store is :redis"
      end
    end
  end
end