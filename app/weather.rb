require './app/yahoo'
require 'date'

# This Weather object is a helper module for communicating
# with the yahoo! weather API, to fetch forecasts for any location
# in the world. It can make queries with the YQL language
# to join several yahoo service providers and parses the
# APIs responses to meaningful and easy to traverse JSON responses
class Weather

  # class constructor
  # it initializes the yahoo API wrapper used by this object.
  #
  # @return Weather
  #
  def initialize()
    @options ||= {}
    @api = YahooApi.new(format: 'json', diagnostics: false)
  end

  # pass configuration to the object
  # in a DSL-like manner, using a block
  # @param &block   a block that must be defined in order to configure the object
  # @return void
  #
  def configure(&block)
    raise ArgumentError, "Block is required." unless block_given?
    yield @options
  end

  # fetch the weather forecast for the specified
  # place, and parse the response to a meaningful structure,
  #
  # the "place" parameter can have multiple formats:
  # * "latitude, longitude": a string with a geographical coordinate.
  # * "city,country": a string with a city, and the optional country.
  # * "zipcode": a zipcode. Currently supports US and Canada only.
  #
  # @param [String] place  a string representing the place
  # @return [Hash]         the parsed weather response
  #
  def forecast(place)
    # add parenteses if a geoposition is provided
    if place =~ /^(-?\d+\.\d+),\s?(-?\d+\.\d+)$/
      place = "(#{place})"
    end

    # make a query to the Yahoo! weather API
    response = @api.yql(
      get_yql_query(place, @options[:items].join(','))
    )

    # parse response to a simpler structure and return it
    formatted_response = transform_forecast_object(
      response.parsed_response['query']['results']['channel']
    )
    return formatted_response
  end

  # ---------------------------------------------------------------------

  private
  # Generate the YQL query for getting the current weather conditions
  # for a specified place, that can be specified either by:
  # * its latitude and longitude
  # * a city name, and a country name (optional)
  # * a zipcode (for US and Canada)
  #
  # @param [String] place   the place string
  # @param [Hash] options   additional options for the query
  #
  # @return [String] a valid YQL query
  #
  def get_yql_query(place, options = '*')
    return %{
      select #{options}
      from weather.forecast
      where woeid in (
        select woeid from geo.places(1)
        where text="#{place}" limit 1
      ) and u='c' limit 1
    }
  end

  # transform the Yahoo API response to a simpler
  # hierarchical structure that can be read by the
  # API clients. This method organizes the normal query response
  # provided by YQL and groups it in a meaningful way.
  #
  # The response will be structured as follows:
  # units: the units used in the forecast (either imperial or metric)
  # location: a hash containing info about the current location
  # today: a hash containing today's forecast
  # today.wind: today's wind conditions
  # today.atmosphere: today's atmosphere conditions
  # today.condition: today's general condition (temperature, forecast, etc)
  # week: an array containing a forecast for the remaining days in the current week
  #
  # @param [Hash] response   the parsed yahoo Response
  # @return [Hash]   the transformed response with a new structure
  #
  def transform_forecast_object(response)
    forecast_response = {}

    lat_lng = {
      latitude:  response['item']['lat'],
      longitude: response['item']['long']
    }
    forecast_response[:date]     = DateTime.now
    forecast_response[:units]    = response['units']
    forecast_response[:location] = response['location'].merge(lat_lng)

    # get higher and lower temperatures for today
    today_forecast = response['item']['forecast'].first
    today_temps    = { high: today_forecast['high'], low: today_forecast['low'] }

    forecast_response[:today] = {
      wind:       response['wind'],
      atmosphere: response['atmosphere'],
      condition:  response['item']['condition'].merge(today_temps)
    }
    forecast_response[:week] = response['item']['forecast'].drop(1)

    return forecast_response
  end
end
