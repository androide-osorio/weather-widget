require "sinatra"
require './app/weather'
require './app/ip_location'
require 'date'
require 'httparty'

get '/' do
  iplocation = IPLocation.new
  fallback_location = iplocation.current

  forecast = Weather.forecast(
    fallback_location["latitude"],
    fallback_location["longitude"]
  )

  return erb :index, locals: {
    forecast: {
      today: forecast.first,
      week: forecast.drop(1)
    }
  }
end

get '/forecast' do
  lat = params[:latitude]
  lon = params[:longitude]
  forecast = Weather.forecast(lat, lon)

  return forecast.to_json
end
