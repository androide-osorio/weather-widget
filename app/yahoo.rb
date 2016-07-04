require 'httparty'
require 'json'

# This class is a simple wrapper for handling communication
# with the Yahoo Public APIs, as well as private ones (those that
# require either OAuth 1 or 2)
class YahooApi
  include HTTParty
  base_uri 'query.yahooapis.com'

  # constructor
  # you can pass a config array to it to specify
  # additional query parameters you want to send to yahoo
  # in a global manner.
  def initialize(config)
    @options = { query: config }
  end

  # This method makes a query to the yahoo's
  # query api, using a YQL string, and sends
  # a either signed or unsigned request to Yahoo
  # @param  [String]             query    a valid YQL query
  # @return [HTTParty::Response]          a response object with the info or errors
  def yql(query)
    # prepare query
    @options[:query].store(:q, query)

    # make request
    return self.class.get("/v1/public/yql", @options)
  end
end
