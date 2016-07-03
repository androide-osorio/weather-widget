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
  end

  helpers do
    include Sprockets::Helpers

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

  # get forecast by mathcing a zipcode
  # For USA postal codes
  get %r{/forecast/zipcode/(?<zipcode>\d{5}(-\d{4})?)} do |zipcode|
    content_type :json
    return zipcode
  end

  # get forecast of specific city and country
  # :country -> must match a 2 letter abbreviation of the country
  # :city    -> match a city name in slug case (e.g:los-angeles)
  get %r{/forecast/(?<country>[A-Z]{2})/city/(?<city>[a-z0-9-]+)} do |country, city|
    content_type :json
    return { country: country, city: city }.to_json
  end

  # get forecast of a specified location
  # by latitude AND longitude
  get '/forecast/location/:latitude,:longitude' do
    content_type :json
    lat = params[:latitude]
    lon = params[:longitude]
    forecast = Weather.forecast(lat, lon)

    return forecast.to_json
  end
end
