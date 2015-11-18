require 'spec_helper'

describe SunlightApi do
  it 'has a version number' do
    expect(SunlightApi::VERSION).not_to be nil
  end
	let (:public_key) { ENV['sunlight_public_key'] }
	let (:private_key) { ENV['sunlight_secret_key'] }
	describe "Testing setup" do
		it "has keys stored in environment variables" do
			expect( public_key.nil? ).to be false
			expect( private_key.nil? ).to be false
		end
	end

	describe 'UrlGenerator' do
		it "Generates urls with proper security credentials" do
			is_test_mode = true
			uri = SunlightApi::UriGenerator.new(public_key, private_key, is_test_mode, "Part", {format: "json"}).url
			url, q_string = uri.split("?")
			q_params = q_string.split("&").map{|key_value_string| key_value_string.split("=")}
			if is_test_mode
				expect( url ).to eq "https://hortservices.sunlightsupply.com/v1/Part"
			else
				expect( url ).to eq "https://services.sunlightsupply.com/v1/Part"
			end
			expect( q_params.select{|e| e.first == "X-ApiKey"}.size ).to eq 1
			expect( q_params.select{|e| e.first == "time"}.size ).to eq 1
			expect( q_params.select{|e| e.first == "signature"}.size ).to eq 1
		end
	end

	describe 'Client' do
		let (:client) { SunlightApi::Client::new(public_key, private_key, true) }

		# Comented out tests passed before but take a while so they are skipped while building new features
		describe 'ArrayOfProductIds' do
			it "Responds with an array of product ids" do
				array_of_product_ids = client.array_of_product_ids
				expect( array_of_product_ids.class ).to be Array
				expect( array_of_product_ids.first.class ).to be String
				expect( array_of_product_ids.size ).to be > 0
			end
		end

		# describe "ProductInfo" do
		# 	it "Responds with hash of all product info for id" do
		# 		array_of_product_ids = client.array_of_product_ids
		# 		id = array_of_product_ids.last
		# 		product_info = client.product_info(id)
		# 		expect( product_info.class ).to be Hash
		# 		expect( product_info["Name"] ).not_to be nil
		# 	end
		# end

		describe "Order" do
			it "Should succsessfully post an order" do
				array_of_product_ids = client.array_of_product_ids
				id = array_of_product_ids.last
				order_params = {
					"PoNumber" => (1..7).to_a.map{|e| (('A'..'Z').to_a + (1..9).to_a).sample}.join(''),
					"SourceId" => "RubyTest",
					"ShippingAddress" => {
						"Name" => "Ruby Testing",
						"Address1" => "12345 Fake St.",
						"Address2" => "Suite #300",
						"City" => "Denver",
						"State" => "CO",
						"Country" => "USA",
						"Zip" => "80003",
						"Phone" => "555-555-5555"
					},
					"PartLineItems" => [
						{"PartId" => id, "Quantity" => "10"}
					],
					"IsWillCall" => "0"
				}
				order_response = client.place_order(order_params)
				expect( order_response.class ).to be Hash
				expect( order_response ).to eq( {} )
			end
		end

		# describe "EachProduct" do
		# 	it "Takes a block" do
		# 		client.each_product do |product|
		# 			expect(product["Name"].nil?).to be false
		# 		end
		# 	end
		# end

	end
end
