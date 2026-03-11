# frozen_string_literal: true

RSpec.describe TaxCalculatorGem::Cache do
  let(:config) { TaxCalculatorGem::Configuration.new }
  let(:cache)  { TaxCalculatorGem::Cache.new(config) }

  describe "#fetch with memory store (default)" do
    it "calls the block on cache miss and returns the value" do
      expect(cache.fetch("key1") { 8.6 }).to eq(8.6)
    end

    it "returns cached value on second call without invoking the block again" do
      call_count = 0
      cache.fetch("key1") { call_count += 1; 8.6 }
      cache.fetch("key1") { call_count += 1; 9.0 }
      expect(call_count).to eq(1)
    end

    it "returns the originally cached value on second call" do
      cache.fetch("key1") { 8.6 }
      expect(cache.fetch("key1") { 9.0 }).to eq(8.6)
    end

    it "stores different keys independently" do
      cache.fetch("key1") { 5.0 }
      cache.fetch("key2") { 7.0 }
      expect(cache.fetch("key1") { 0 }).to eq(5.0)
      expect(cache.fetch("key2") { 0 }).to eq(7.0)
    end

    it "re-fetches after TTL expiry" do
      config.cache_ttl = 60
      now = Time.now
      allow(Time).to receive(:now).and_return(now)
      cache.fetch("key1") { 8.6 }

      allow(Time).to receive(:now).and_return(now + 61)
      expect(cache.fetch("key1") { 9.9 }).to eq(9.9)
    end

    it "does not re-fetch before TTL expires" do
      config.cache_ttl = 60
      now = Time.now
      allow(Time).to receive(:now).and_return(now)
      cache.fetch("key1") { 8.6 }

      allow(Time).to receive(:now).and_return(now + 59)
      expect(cache.fetch("key1") { 9.9 }).to eq(8.6)
    end

    it "clears all entries on #clear" do
      cache.fetch("key1") { 8.6 }
      cache.clear
      call_count = 0
      cache.fetch("key1") { call_count += 1; 5.0 }
      expect(call_count).to eq(1)
    end
  end

  describe "#fetch with redis store" do
    let(:redis_double) { double("Redis") }

    before do
      config.cache_store = :redis
      allow(cache).to receive(:redis_client).and_return(redis_double)
    end

    it "returns cached value from Redis without calling the block" do
      allow(redis_double).to receive(:get).with("key1").and_return("10.6")
      call_count = 0
      value = cache.fetch("key1") { call_count += 1; 0.0 }
      expect(value).to eq(10.6)
      expect(call_count).to eq(0)
    end

    it "calls block and stores result in Redis on cache miss" do
      allow(redis_double).to receive(:get).with("key1").and_return(nil)
      allow(redis_double).to receive(:setex).with("key1", config.cache_ttl, "8.6")
      value = cache.fetch("key1") { 8.6 }
      expect(value).to eq(8.6)
      expect(redis_double).to have_received(:setex).with("key1", config.cache_ttl, "8.6")
    end
  end
end
