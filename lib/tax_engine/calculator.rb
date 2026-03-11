module TaxCalculatorGem
  class Calculator
    def self.calculate(price:, location:, manual_rate: nil, category: nil)
      rate = manual_rate || ApiClient.fetch_tax_rate(location, category)
      tax = (price * rate / 100.0).round(2)
      tax
    end

    def self.total_price(price:, location:, manual_rate: nil, category: nil)
      price + calculate(price: price, location: location, manual_rate: manual_rate, category: category)
    end

    def self.calculate_for_items(items:, location:)
      total_tax = 0
      total_price = 0
      items.each do |item|
        item_tax = calculate(price: item[:price] * item[:quantity], location: location, category: item[:category])
        total_tax += item_tax
        total_price += item[:price] * item[:quantity] + item_tax
      end
      { total_tax: total_tax.round(2), total_price: total_price.round(2) }
    end
  end
end