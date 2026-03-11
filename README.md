# TaxCalculatorGem

A Ruby gem for calculating US sales tax. It fetches live tax rates from the Washington State DOR API and supports in-memory or Redis caching to avoid redundant API calls.

---

## Installation

Add this to your `Gemfile`:

```ruby
gem "tax_calculator_gem"
```

Then run:

```bash
bundle install
```

If you plan to use **Redis caching**, also add:

```ruby
gem "redis"
```

---

## Configuration

### Plain Ruby project

Create an initializer file (e.g. `config/tax_engine.rb`) and require it at startup:

```ruby
require "tax_calculator_gem"

TaxCalculatorGem.configure do |config|
  config.api_key       = "your_api_key"      # if required by the tax API
  config.default_state = "WA"                # default US state

  # Cache — choose :memory (default) or :redis
  config.cache_store = :memory
  config.cache_ttl   = 3600                  # seconds (1 hour)
end
```

### Rails project

Create `config/initializers/tax_calculator_gem.rb`:

```ruby
TaxCalculatorGem.configure do |config|
  config.api_key       = ENV["TAX_API_KEY"]
  config.default_state = ENV.fetch("TAX_DEFAULT_STATE", "WA")

  config.cache_store = :memory   # or :redis
  config.cache_ttl   = 3600
end
```

### Using Redis cache

```ruby
TaxCalculatorGem.configure do |config|
  config.cache_store = :redis
  config.redis_url   = ENV.fetch("REDIS_URL", "redis://localhost:6379/0")
  config.cache_ttl   = 3600
end
```

---

## Configuration options

| Option          | Type    | Default                         | Description                                 |
|-----------------|---------|---------------------------------|---------------------------------------------|
| `api_key`       | String  | `nil`                           | API key (reserved for future auth)          |
| `default_state` | String  | `"WA"`                          | Default US state for tax lookups            |
| `cache_store`   | Symbol  | `:memory`                       | Cache backend: `:memory` or `:redis`        |
| `cache_ttl`     | Integer | `3600`                          | Cache expiry in seconds                     |
| `redis_url`     | String  | `"redis://localhost:6379/0"`    | Redis connection URL (required for `:redis`)|

---

## Usage

### Calculate tax on a single item

```ruby
location = { addr: "6500 Linderson Way", city: "Olympia", zip: "98501" }

# Using a manual rate (no API call)
tax = TaxCalculatorGem.calculate(price: 100.0, location: location, manual_rate: 10.0)
# => 10.0

# Using the live API rate
tax = TaxCalculatorGem.calculate(price: 100.0, location: location)
```

### Get total price (price + tax)

```ruby
total = TaxCalculatorGem.total_price(price: 100.0, location: location, manual_rate: 10.0)
# => 110.0
```

### Calculate tax for a cart of items

```ruby
items = [
  { price: 50.0, quantity: 2, category: "general" },
  { price: 30.0, quantity: 1, category: "general" }
]

result = TaxCalculatorGem.calculate_for_items(items: items, location: location)
# => { total_tax: 13.0, total_price: 143.0 }
```

### Manually clear the cache

```ruby
TaxCalculatorGem.reset_cache!
```

---

## Error handling

```ruby
rescue TaxCalculatorGem::InvalidLocationError => e
  # Missing :addr, :city, or :zip in the location hash

rescue TaxCalculatorGem::ApiError => e
  # HTTP failure or unexpected API response

rescue TaxCalculatorGem::CalculationError => e
  # Calculation-level error
end
```

