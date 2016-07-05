/**
 * declare angular application
 */
var App = window.App = angular.module('WeatherApp', [
  'angularMoment',
  'slugifier'
]);

// configure API urls and endpoints as global constants in the app
App.constant('API_URL', '')
  .constant('API_ENDPOINTS', {
    zipcodes: '/forecast/zipcode/:zipcode',
    latlong: '/forecast/location',
    location: '/forecast/country/:country/city/:city',
    places: '/places'
  })
  .constant('GEO_IP_URL', '/my-location');

App.value('currentForecast', window.forecast);
