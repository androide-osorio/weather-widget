require 'httparty'

# Or wrap things up in your own class
class IPLocation
  include HTTParty
  base_uri 'freegeoip.net'


  def current
    self.class.get("/json")
  end
end
