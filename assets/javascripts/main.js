/**
 * declare angular application
 */
var App = window.App = angular.module('WeatherApp', ['ngAnimate']);

// configure API urls and endpoints as global constants in the app
App.constant('API_URL', '/')
  .constant('API_ENDPOINTS', {
    zipcodes: 'forecast/zipcode/:zipcode',
    latlong: 'forecast/location/:latitude,longitude',
    location: 'forecast/country/:country/city/:city'
  })
  .constant('GEO_IP_URL', '/my-location');
