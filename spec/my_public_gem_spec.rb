# frozen_string_literal: true

RSpec.describe TaxCalculatorGem do
  it "has a version number" do
    expect(TaxCalculatorGem::VERSION).not_to be nil
  end

  it "delegates calculate to Calculator" do
    location = { addr: "6500 Linderson Way", city: "Olympia", zip: "98501" }
    expect(TaxCalculatorGem::Calculator).to receive(:calculate).with(price: 100, location: location, manual_rate: 5.0, category: nil).and_call_original
    result = TaxCalculatorGem.calculate(price: 100, location: location, manual_rate: 5.0)
    expect(result).to eq(5.0)
  end

  it "delegates total_price to Calculator" do
    location = { addr: "6500 Linderson Way", city: "Olympia", zip: "98501" }
    result = TaxCalculatorGem.total_price(price: 200, location: location, manual_rate: 10.0)
    expect(result).to eq(220.0)
  end

  it "supports configure block" do
    TaxCalculatorGem.configure do |config|
      config.default_state = "OR"
      config.api_key = "test_key"
    end
    expect(TaxCalculatorGem.configuration.default_state).to eq("OR")
    expect(TaxCalculatorGem.configuration.api_key).to eq("test_key")
    # reset
    TaxCalculatorGem.instance_variable_set(:@configuration, nil)
  end
end
