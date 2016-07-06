require 'sprockets'
require 'uglifier'
require 'sass'

require 'sinatra/base'
require 'sinatra/sprockets-helpers'

require './app/weather'
require './app/ip_location'

class WeatherApplication < Sinatra::Base
  register Sinatra::Sprockets::Helpers

  set :root, File.dirname(__FILE__)
  set :sprockets, Sprockets::Environment.new(root)
  set :assets_prefix, '/assets'
  set :digest_assets, false
  set :yahoo, YahooApi.new(format: 'json', diagnostics: false)
  set :weather, Weather.new()

  configure do
    # Setup Sprockets
    sprockets.append_path File.join(root, 'assets', 'stylesheets')
    sprockets.append_path File.join(root, 'assets', 'javascripts')
    sprockets.append_path File.join(root, 'assets', 'images')
    sprockets.append_path File.join(root, 'assets', 'videos')

    # configure Sprockets processors and compressors
    sprockets.js_compressor  = :uglify
    sprockets.css_compressor = :scss

    # Configure Sprockets::Helpers (if necessary)
    Sprockets::Helpers.configure do |config|
      config.environment = sprockets
      config.prefix      = assets_prefix
      config.digest      = digest_assets
      config.public_path = public_folder

      # Force to debug mode in development mode
      # Debug mode automatically sets
      # expand = true, digest = false, manifest = false
      config.debug       = true if development?
    end

    # setup weather forecaster
    weather.configure do |options|
      options[:items] = ['*']
    end
  end

  helpers do
    include Sprockets::Helpers

    def slugify(str)
      return str.gsub(' ', '-').downcase
    end

    # Alternative method for telling Sprockets::Helpers which
    # Sprockets environment to use.
    # def assets_environment
    #   settings.sprockets
    # end
  end

  # -------------------------------------------------------------------
  # get assets
  get "/assets/*" do
    env["PATH_INFO"].sub!("/assets", "")
    settings.sprockets.call(env)
  end

  get '/' do
    iplocation = IPLocation.new
    fallback_location = iplocation.current

    latitude = fallback_location["latitude"]
    longitude = fallback_location["longitude"]

    forecast = settings.weather.forecast("#{latitude},#{longitude}")

    return erb :index, locals: { forecast: forecast }
  end

  # -------------------------------------------------------------------
  # ====================================
  # API Routes
  # ====================================

  # API endpoint for returning the client's current
  # location using IP based location. This endpoint
  # is used in case the HTML5 location fails
  # or is rejected by the client
  get '/my-location' do
    content_type :json

    ip_location_service = IPLocation.new()
    location = ip_location_service.current()

    location_res = {
      latitude:  location['latitude'],
      longitude: location['longitude'],
      city:      location['city'],
      region:    { code: location['region_code'], name: location['region_name'] },
      country:   { code: location['country_code'], name: location['country_name'] },
    }

    return location_res.to_json
  end

  get '/places' do
    content_type :json
    query = params['query']
    places = settings.yahoo.find_place(query,[
      'woeid', 'name', 'country',
      'admin1', 'admin2', 'locality1', 'locality2', 'centroid'
    ])

    return places.to_json
  end

  # get forecast by mathcing a zipcode
  # For USA postal codes
  get %r{/forecast/zipcode/(?<zipcode>\d{5}(-\d{4})?)} do |zipcode|
    content_type :json
    forecast = settings.weather.forecast("#{zipcode}")

    return forecast.to_json
  end

  # get forecast by mathcing a zipcode
  # For Canada postal codes
  get %r{/forecast/zipcode/(?<zipcode>[ABCEGHJKLMNPRSTVXY]{1}\d{1}[A-Z]{1}-?\d{1}[A-Z]{1}\d{1})} do |zipcode|
    content_type :json
    forecast = settings.weather.forecast("#{zipcode}")

    return forecast.to_json
  end

  # get forecast of specific city and country
  # :country -> must match a 2 letter abbreviation of the country
  # :city    -> match a city name in slug case (e.g:los-angeles)
  get %r{/forecast/country/(?<country>[A-Z]{2})/city/(?<city>[a-z0-9-]+)} do |country, city|
    content_type :json
    forecast = settings.weather.forecast("#{city},#{country}")

    return forecast.to_json
  end

  # get forecast of a specified location
  # by latitude AND longitude
  get %r{/forecast/location/(?<latitude>-?\d+\.\d+),(?<longitude>-?\d+\.\d+)} do |latitude, longitude|
    content_type :json
    forecast = settings.weather.forecast("#{latitude},#{longitude}")

    return forecast.to_json
  end
end
