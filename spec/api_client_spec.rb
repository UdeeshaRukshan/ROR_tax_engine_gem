# frozen_string_literal: true

RSpec.describe TaxCalculatorGem::ApiClient do
  let(:location) { { addr: "6500 Linderson Way", city: "Olympia", zip: "98501" } }

  before { TaxCalculatorGem.reset_cache! }

  describe ".fetch_tax_rate" do
    it "raises InvalidLocationError when addr is missing" do
      expect {
        TaxCalculatorGem::ApiClient.fetch_tax_rate({ city: "Olympia", zip: "98501" })
      }.to raise_error(TaxCalculatorGem::InvalidLocationError, /addr, :city, and :zip/)
    end

    it "raises InvalidLocationError when city is missing" do
      expect {
        TaxCalculatorGem::ApiClient.fetch_tax_rate({ addr: "123 Main", zip: "98501" })
      }.to raise_error(TaxCalculatorGem::InvalidLocationError)
    end

    it "raises InvalidLocationError when zip is missing" do
      expect {
        TaxCalculatorGem::ApiClient.fetch_tax_rate({ addr: "123 Main", city: "Olympia" })
      }.to raise_error(TaxCalculatorGem::InvalidLocationError)
    end

    context "with a successful HTTP response" do
      let(:xml_body) do
        <<~XML
          <?xml version="1.0"?>
          <AddressRateResponse>
            <Rate LocationCode="3232">0.106</Rate>
            <SalesTaxRate>10.6</SalesTaxRate>
          </AddressRateResponse>
        XML
      end

      before do
        response = instance_double(Net::HTTPSuccess, is_a?: true, body: xml_body, code: "200")
        allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
        allow(Net::HTTP).to receive(:get_response).and_return(response)
      end

      it "returns the tax rate as a float from SalesTaxRate node" do
        rate = TaxCalculatorGem::ApiClient.fetch_tax_rate(location)
        expect(rate).to eq(10.6)
      end
    end

    context "with a failed HTTP response" do
      before do
        response = instance_double(Net::HTTPServerError, code: "500")
        allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)
        allow(Net::HTTP).to receive(:get_response).and_return(response)
      end

      it "raises ApiError with the response code" do
        expect {
          TaxCalculatorGem::ApiClient.fetch_tax_rate(location)
        }.to raise_error(TaxCalculatorGem::ApiError, /500/)
      end
    end

    context "with caching" do
      let(:xml_body) do
        <<~XML
          <?xml version="1.0"?>
          <AddressRateResponse>
            <SalesTaxRate>10.6</SalesTaxRate>
          </AddressRateResponse>
        XML
      end

      before do
        response = instance_double(Net::HTTPSuccess, body: xml_body, code: "200")
        allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
        allow(Net::HTTP).to receive(:get_response).and_return(response)
      end

      it "only makes one HTTP request for the same location" do
        TaxCalculatorGem::ApiClient.fetch_tax_rate(location)
        TaxCalculatorGem::ApiClient.fetch_tax_rate(location)
        expect(Net::HTTP).to have_received(:get_response).once
      end

      it "returns the same cached rate on repeated calls" do
        first  = TaxCalculatorGem::ApiClient.fetch_tax_rate(location)
        second = TaxCalculatorGem::ApiClient.fetch_tax_rate(location)
        expect(second).to eq(first)
      end

      it "makes separate HTTP requests for different locations" do
        other = { addr: "1600 Pennsylvania Ave", city: "Seattle", zip: "98101" }
        TaxCalculatorGem::ApiClient.fetch_tax_rate(location)
        TaxCalculatorGem::ApiClient.fetch_tax_rate(other)
        expect(Net::HTTP).to have_received(:get_response).twice
      end

      it "re-fetches after cache is reset" do
        TaxCalculatorGem::ApiClient.fetch_tax_rate(location)
        TaxCalculatorGem.reset_cache!
        TaxCalculatorGem::ApiClient.fetch_tax_rate(location)
        expect(Net::HTTP).to have_received(:get_response).twice
      end
    end
  end
end
