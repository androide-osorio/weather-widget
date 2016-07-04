require './oauth_util'
require 'httparty'
require 'net/http'
require 'json'

module Yahoo
  class Api
    include HTTParty
    base_uri 'query.yahooapis.com'

    def initialize(config)
      @options = { query: config }
    end

    def yql(query)
      # prepare query
      request_params = { query: query }
      request_params.merge!(@options)
      query_options = URI.encode_www_form(request_params)

      # make request
      return self.class.get("/v1/public/yql", request_params)
    end
  end

  # class Api
  #   @@options = {}
  #   @@api_url = 'http://query.yahooapis.com/v1/public/yql'
  #
  #   class << self
  #     def options
  #       @@options
  #     end
  #
  #     def configure(&proc)
  #       raise ArgumentError, "Block is required." unless block_given?
  #       yield @@options
  #     end
  #
  #     def yql(query)
  #       # prepare query
  #       request_params = { query: query }
  #       request_params.merge!(@@options[:query])
  #       query_options = URI.encode_www_form(request_params)
  #
  #       # make request
  #       url, request = get_signed_request("#{@@api_url}?#{query_options}")
  #       Net::HTTP::start(url.host) do |http|
  #         response = http.request(req)
  #         return JSON.parse(response.body)
  #       end
  #     end
  #
  #     def get_signed_request(url)
  #       CONSUMER_KEY    = @@options[:apikey]
  #       CONSUMER_SECRET = @@options[:apisecret]
  # 
  #       o = OAuthUtil.new()
  #       o.consumer_key = CONSUMER_KEY;
  #       o.consumer_secret = CONSUMER_SECRET;
  #
  #       parsed_url = URI.parse( url )
  #
  #       return [
  #         parsed_url,
  #         Net::HTTP::Get.new "#{ parsed_url.path }?#{ o.sign(parsed_url).query_string }"
  #       ]
  #     end
  #   end
  # end
end
