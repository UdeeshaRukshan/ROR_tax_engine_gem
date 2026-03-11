# frozen_string_literal: true

RSpec.describe TaxCalculatorGem::Calculator do
  let(:location) { { addr: "6500 Linderson Way", city: "Olympia", zip: "98501" } }

  describe ".calculate" do
    it "calculates tax using manual_rate" do
      expect(TaxCalculatorGem::Calculator.calculate(price: 100, location: location, manual_rate: 10.0)).to eq(10.0)
    end

    it "rounds tax to 2 decimal places" do
      expect(TaxCalculatorGem::Calculator.calculate(price: 33.33, location: location, manual_rate: 10.0)).to eq(3.33)
    end

    it "fetches rate from API when no manual_rate given" do
      allow(TaxCalculatorGem::ApiClient).to receive(:fetch_tax_rate).and_return(8.6)
      expect(TaxCalculatorGem::Calculator.calculate(price: 100, location: location)).to eq(8.6)
    end

    it "passes category to ApiClient" do
      allow(TaxCalculatorGem::ApiClient).to receive(:fetch_tax_rate).with(location, "food").and_return(5.0)
      result = TaxCalculatorGem::Calculator.calculate(price: 200, location: location, category: "food")
      expect(result).to eq(10.0)
    end
  end

  describe ".total_price" do
    it "returns price + tax" do
      expect(TaxCalculatorGem::Calculator.total_price(price: 100, location: location, manual_rate: 10.0)).to eq(110.0)
    end

    it "handles zero tax rate" do
      expect(TaxCalculatorGem::Calculator.total_price(price: 50, location: location, manual_rate: 0.0)).to eq(50.0)
    end
  end

  describe ".calculate_for_items" do
    before do
      allow(TaxCalculatorGem::ApiClient).to receive(:fetch_tax_rate).and_return(10.0)
    end

    it "calculates total_tax and total_price for multiple items" do
      items = [
        { price: 50, quantity: 2, category: "general" },
        { price: 30, quantity: 1, category: "general" }
      ]
      result = TaxCalculatorGem::Calculator.calculate_for_items(items: items, location: location)
      # (50*2) + (30*1) = 130; tax 10% = 13.0; total = 143.0
      expect(result[:total_tax]).to eq(13.0)
      expect(result[:total_price]).to eq(143.0)
    end

    it "returns zero totals for empty items" do
      result = TaxCalculatorGem::Calculator.calculate_for_items(items: [], location: location)
      expect(result[:total_tax]).to eq(0.0)
      expect(result[:total_price]).to eq(0.0)
    end
  end
end
