require "sinatra"
require "./app/weather"
require 'date'

get '/' do
  weather = Weather.new
  forecast = weather.get_forecast(4.5255272,-75.6382543)

  return erb :index, locals: { forecast: forecast.daily }
end
