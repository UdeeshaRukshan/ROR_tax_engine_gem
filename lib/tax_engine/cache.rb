# frozen_string_literal: true

module TaxCalculatorGem
  class Cache
    def initialize(config)
      @config = config
      @memory_store = {}
      @mutex = Mutex.new
    end

    def fetch(key, &block)
      case @config.cache_store
      when :redis
        fetch_from_redis(key, @config.cache_ttl, &block)
      else
        fetch_from_memory(key, @config.cache_ttl, &block)
      end
    end

    def clear
      @mutex.synchronize { @memory_store.clear }
    end

    private

    def fetch_from_memory(key, ttl)
      @mutex.synchronize do
        entry = @memory_store[key]
        if entry && entry[:expires_at] > Time.now
          return entry[:value]
        end
        value = yield
        @memory_store[key] = { value: value, expires_at: Time.now + ttl }
        value
      end
    end

    def fetch_from_redis(key, ttl)
      cached = redis_client.get(key)
      return cached.to_f if cached

      value = yield
      redis_client.setex(key, ttl, value.to_s)
      value
    end

    def redis_client
      @redis_client ||= begin
        require "redis"
        Redis.new(url: @config.redis_url)
      rescue LoadError
        raise "Add `gem 'redis'` to your Gemfile to use the Redis cache store"
      end
    end
  end
end
