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

    return response
  end

  private
  def transform_forecast_object()
  end
end
