require './yahoo'
require 'httparty'
require 'date'

class Weather
  def initialize()
    Yahoo::Api.configure do |config|
      config[:apikey] = ENV['YAHOO_CONSUMER_KEY']
      config[:apisecret] = ENV['YAHOO_CONSUMER_SECRET']

      config[:query] = {
        format: 'json'
      }
    end
  end

  def forecast(place)
    response = Yahoo::Api.yql(%{
      select * from weather.forecast
      where woeid in (
        select woeid from geo.places(1)
        where text="#{place}" limit 1
      ) and u='c'
    })

    return response
  end
end
