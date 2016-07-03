require 'forecast_io'
require 'date'

class Weather

  def initialize(options = {})
    @options = options
    api_key = ENV['WEATHER_API_KEY']

    ForecastIO.configure do |config|
      config.api_key = api_key
    end
  end

  def get_forecast(latitude, longitude)
    forecast = ForecastIO.forecast(latitude, longitude, params: {
      units: 'si',
      exclude: 'minutely, hourly, flags'
    })
    return forecast
  end

  def self.forecast(latitude, longitude)
    weather = Weather.new
    forecast = weather.get_forecast(latitude, longitude)

    payload = forecast.daily.data.each do |day|
      day['time'] = DateTime.strptime(day['time'].to_s,'%s')
    end

    return payload
  end
end
