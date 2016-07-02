require 'forecast_io'

class Weather

  def initialize()
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
end
