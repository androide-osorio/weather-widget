require 'httparty'

# Thisi a wrapper class for communicating
# with an IP based location service
class IPLocation
  include HTTParty
  base_uri 'freegeoip.net'

  # get the current client's geographical location,
  # using and IP lookup, and a json format
  # @return [HTTParty:Response]   a response with the client's location, if available
  def current
    self.class.get("/json")
  end
end
