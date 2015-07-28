require "sunlight_api/version"
require "rquest"
require "json"
# Fix ruby's DNS lookup issues
require "resolv-replace.rb"

module SunlightApi
	class Client
		def initialize( public_key, private_key )
			@public_key = public_key
			@private_key = private_key
		end

		def request( action )
			uri = SunlightApi::UriGenerator::new(@public_key, @private_key, action, {format: "json"}).url
			rclient = Rquest::new({verb: :get, uri: uri})
			body = rclient.send
			return nil if body.class == Hash and not body['error'].nil?
			JSON::parse( body )
		end

		def inventory
			request("inventory")
		end

		def array_of_product_ids
			@inventroy = inventory
			unless @inventroy.nil?
				@inventroy.inject([]){|r,v| r.push(v["Id"])}
			else
				[]
			end
		end

		def product_info( id )
			request("part/#{id}")
		end

		def product_price_breaks( id )
			request("pricebreak/#{id}")
		end

		def each_product( &block )
			array_of_product_ids.each do |product_id|
				product = product_info( product_id )
				next unless product
				price_breaks = product_price_breaks(product_id)
				price_breaks ||= []
				product["PriceBreaks"] = price_breaks
				yield product
			end
		end

		def products_array
			request("part")
		end
	end
	class UriGenerator
		attr_reader :url
		def initialize( public_key, private_key, uri_suffix, get_params={} )
			@public_key = public_key
			@private_key = private_key
			@base_url = "https://services.sunlightsupply.com/v1/#{uri_suffix}?"
			@get_params = get_params
			@time_stamp = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
			append_get_params
			append_api_key
			append_time_stamp
			append_signature
		end

		def append_get_params
			@get_params.each_with_index do |(key,value), i|
				@base_url += "#{key}=#{value}"
				@base_url += "&" unless i == (@get_params.size - 1)
			end
		end

		def append_api_key
			@base_url += "&" if @get_params.size > 0
			@base_url += "X-ApiKey=#{@public_key}"
		end

		def append_time_stamp
			@base_url += "&time=#{@time_stamp}"
		end

		def append_signature
			@digest  = OpenSSL::Digest::Digest.new('sha256')
			@signature = OpenSSL::HMAC.hexdigest(@digest, @private_key, @base_url).upcase
			@url = "#{@base_url}&signature=#{@signature}"
		end
	end
end
