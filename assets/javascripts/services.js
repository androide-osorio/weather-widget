/**
 * Application services
 */

var App = angular.module('WeatherApp');

App.factory('PlaceFinder', function(API_ENDPOINTS, $http, $q, GeoPosition) {
  var apiUrl = API_ENDPOINTS.places;

  var find = function(placeQuery) {
    return $http.get(apiUrl, { params: { query: placeQuery } })
      .then(function(response) {
        return new GeoPosition({
          coords: {
            latitude: response.data.place.centroid.latitude,
            longitude: response.data.place.centroid.longitude
          },
          timestamp: new Date(),
          info: {
            id: response.data.place.woeid,
            country: {
              code: response.data.place.country.code,
              name: response.data.place.country.content,
            },
            region: {
              code: response.data.place.admin1.code,
              name: response.data.place.admin1.content,
            },
            county: response.data.place.admin2 ? response.data.place.admin2.content : null,
            city: response.data.place.locality1 ? response.data.place.locality1.content : null,
            suburb: response.data.place.locality2 ? response.data.place.locality2.content : null
          }
        });
      }, function(error) {
        return error;
      });
  }

  return {
    find: find
  };
});

App.factory('Weather', function($http, $q, API_ENDPOINTS) {

  var forecastUrl = API_ENDPOINTS.latlong;

  var forecast = function(latitude, longitude) {
    return $http.get(forecastUrl + '/' + latitude + ',' + longitude)
      .then(function(forecast) {
        return forecast;
      }, function(error) {
        console.error(error);
      })
  };

  return {
    forecast: forecast
  }
});
//---------------------------------------------------------------
/* --------------------------------- *
 * IPLocator Class
 * --------------------------------- */
App.factory('IPLocator', function(GEO_IP_URL, $http) {
  var IPLocator = function(url) {
    this.url = url;
  };

  IPLocator.getCurrentPosition = function(resolve, reject) {
    var self = this;

    return $http.get(GEO_IP_URL + '/json')
      .then(function(response) {
        resolve({
          coords: {latitude: response.latitude, longitude: response.longitude},
          timestamp: new Date()
        })
      }, function(error) {
        reject({ code: '', message: error});
      });
  };

  return IPLocator;
});

//---------------------------------------------------------------
/* --------------------------------- *
 * GeoLocator Class
 * --------------------------------- */
App.factory('Geolocation', function(GeoPosition, IPLocator, $q) {
  var geolocationSupport = 'undefined' !== typeof(navigator.geolocation) && navigator.geolocation !== null;

  var Geolocation = function() {
  	if(geolocationSupport) {
  		this.locator = navigator.geolocation;
  	} else {
  		//use IP based geolocation service
  		this.locator = IPGeolocator;
  	}
  };

  Geolocation.GEOLOCATION_PROVIDERS = {};
  Geolocation.LOCATION_TIMEOUT      = 5000;

  Geolocation.prototype.currentPosition = function() {
    var self = this;

  	var deferredPos = $document.querySelector('selector')(function(resolve, reject) {
      //locate the user and resolve the deferred position
    	self.locator.getCurrentPosition(
    		function(position) {
    			var pos = new GeoPosition({
    				coords    : position.coords,
    				timestamp : position.timestamp
    			});

    			resolve(pos);
    		},
    		function(error) {
    			var msg = '';

    			switch(error.code) {
    				case error.PERMISSION_DENIED:
            msg = "You denied permission for geolocation. Falling back to IP based location";
            self.switchGeolocationProviderTo(IPLocator);
    				break;
    				case error.POSITION_UNAVAILABLE: msg = "We couldn't find you on the map.";
    				break;
    				case error.TIMEOUT:              msg = "Sorry! we ran out of time localizing you.";
    				break;
    				case error.UNKNOWN_ERROR:
            default:
              msg = "An unknown error occurred.";
    				  break;
    			}
    			reject({ code: error.code, message: msg });
    		},
    		{ timeout: Geolocation.LOCATION_TIMEOUT }
    	);
    });

    return deferredPos;
  }

  Geolocation.prototype.switchGeolocationProviderTo = function(provider) {
    this.locator = provider;
  };

  Geolocation.prototype.getGeolocationProvider = function() {
    return this.locator;
  };
});

//---------------------------------------------------------------
/* --------------------------------- *
 * GeoPosition Class
 * --------------------------------- */

App.factory('GeoPosition', function() {
  var GeoPosition = function(options, timestamp) {
  	this.latitude  = parseFloat(options.coords.latitude);
  	this.longitude = parseFloat(options.coords.longitude);
    this.info = options.info;
  	this.timestamp = timestamp;
  };

  GeoPosition.prototype.toString = function() {
  	return this.info.city.name + ", " + this.info.state.name + ", " + this.info.country.name;
  };

  GeoPosition.prototype.setCoords = function(latitude, longitude) {
    this.latitude = latitude;
    this.longitude = longitude;
  };

  return GeoPosition;
});
