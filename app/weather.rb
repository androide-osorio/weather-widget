require './app/yahoo'
require 'date'

class Weather
  def initialize()
    @api = YahooApi.new(format: 'json', diagnostics: false)
  end

  def forecast(place)
    if place =~ /^(-?\d+\.\d+),\s?(-?\d+\.\d+)$/
      place = "(#{place})"
    end

    response = @api.yql(%{
      select * from weather.forecast
      where woeid in (
        select woeid from geo.places(1)
        where text="#{place}" limit 1
      ) and u='c'
    })

    return response
  end
end
