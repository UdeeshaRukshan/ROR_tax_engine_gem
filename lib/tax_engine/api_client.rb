require "net/http"
require "uri"
require "nokogiri"

module TaxCalculatorGem
  class ApiClient
    BASE_URL = "https://webgis.dor.wa.gov/webapi/AddressRates.aspx"

    # category: optional, currently not used
    def self.fetch_tax_rate(location, category = nil)
      raise InvalidLocationError, "Location must include :addr, :city, and :zip" unless
        location[:addr] && location[:city] && location[:zip]

      cache_key = "tax_rate:#{location[:addr]}:#{location[:city]}:#{location[:zip]}:#{category}"
      TaxCalculatorGem.cache.fetch(cache_key) { fetch_from_api(location) }
    rescue InvalidLocationError, ApiError
      raise
    rescue StandardError => e
      raise ApiError, "ApiClient Error: #{e.message}"
    end

    def self.fetch_from_api(location)
      uri = URI(BASE_URL)
      uri.query = URI.encode_www_form(
        output: "xml",
        addr: location[:addr],
        city: location[:city],
        zip: location[:zip]
      )

      response = Net::HTTP.get_response(uri)

      raise ApiError, "API request failed with code #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      doc = Nokogiri::XML(response.body)

      tax_node = doc.at_xpath("//SalesTaxRate") || doc.at_xpath("//Rate")
      raise ApiError, "Tax rate not found in API response" unless tax_node

      tax_node.content.to_f.round(2)
    end
    private_class_method :fetch_from_api
  end
end