require './app/yahoo'
require 'date'

# location,wind,atmosphere,item.condition,item.forecast
class Weather

  def initialize()
    @options ||= {}
    @api = YahooApi.new(format: 'json', diagnostics: false)
  end

  def configure(&block)
    raise ArgumentError, "Block is required." unless block_given?
    yield @options
  end

  def forecast(place)
    if place =~ /^(-?\d+\.\d+),\s?(-?\d+\.\d+)$/
      place = "(#{place})"
    end

    response = @api.yql(%{
      select #{@options[:items].join(',')}
      from weather.forecast
      where woeid in (
        select woeid from geo.places(1)
        where text="#{place}" limit 1
      ) and u='c' limit 1
    })

    formatted_response = transform_forecast_object(
      response.parsed_response['query']['results']['channel']
    )
    return formatted_response
  end

  private
  def transform_forecast_object(response)
    forecast_response = {}

    lat_lng = {
      latitude: response['item']['lat'],
      longitude: response['item']['long']
    }
    forecast_response[:units] = response['units']
    forecast_response[:location] = response['location'].merge(lat_lng)

    # get higher and lower temperatures for today
    today_forecast = response['item']['forecast'].first
    today_temps    = { high: today_forecast['high'], low: today_forecast['low'] }

    forecast_response[:today] = {
      wind: response['wind'],
      atmosphere: response['atmosphere'],
      condition: response['item']['condition'].merge(today_temps)
    }
    forecast_response[:week] = response['item']['forecast'].drop(1)

    return forecast_response
  end
end
