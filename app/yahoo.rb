require 'httparty'
require 'json'

class YahooApi
  include HTTParty
  base_uri 'query.yahooapis.com'

  def initialize(config)
    @options = { query: config }
  end

  def yql(query)
    # prepare query
    @options[:query].store(:q, query)

    # make request
    return self.class.get("/v1/public/yql", @options)
  end
end
