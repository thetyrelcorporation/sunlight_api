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
			uri = SunlightApi::UriGenerator.new(public_key, private_key, "Part", {format: "json"}).url
			url, q_string = uri.split("?")
			q_params = q_string.split("&").map{|key_value_string| key_value_string.split("=")}
			expect( url ).to eq "https://services.sunlightsupply.com/v1/Part"
			expect( q_params.select{|e| e.first == "X-ApiKey"}.size ).to eq 1
			expect( q_params.select{|e| e.first == "time"}.size ).to eq 1
			expect( q_params.select{|e| e.first == "signature"}.size ).to eq 1
		end
	end

	describe 'Client' do
		let (:client) { SunlightApi::Client::new(public_key, private_key) }
		describe 'ArrayOfProductIds' do
			it "Responds with an array of product ids" do
				array_of_product_ids = client.array_of_product_ids
				expect( array_of_product_ids.class ).to be Array
				expect( array_of_product_ids.first.class ).to be String
				expect( array_of_product_ids.size ).to be > 0
			end
		end

		describe "ProductInfo" do
			it "Responds with hash of all product info for id" do
				array_of_product_ids = client.array_of_product_ids
				id = array_of_product_ids.last
				product_info = client.product_info(id)
				expect( product_info.class ).to be Hash
				expect( product_info["Name"] ).not_to be nil
			end
		end

		# Test takes forever here for api reference
		# describe "EachProduct" do
		# 	it "Takes a block" do
		# 		client.each_product do |product|
		# 			expect(product["Name"].nil?).to be false
		# 		end
		# 	end
		# end

	end
end
