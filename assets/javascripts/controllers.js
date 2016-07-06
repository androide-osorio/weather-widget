
var App = angular.module('WeatherApp');

App.controller('WeatherWidgetController',
['$scope', 'PlaceFinder', 'Weather', 'currentForecast', function($scope, PlaceFinder, Weather, currentForecast) {
  this.isPopupOen = false;
  $scope.forecast = currentForecast;

  this.togglePopup = function() {
    this.isPopupOpen = !this.isPopupOpen
  };

  this.getForecast = function(lat, long) {
    var self = this;
    Weather.forecast(lat, long).then(function(response) {
      $scope.forecast = response.data;
      self.togglePopup();
    });
  }

  this.findPlace = function(placeQuery) {
    var self = this;
    PlaceFinder.find(placeQuery)
      .then(function(positions) {
        if(positions instanceof Array) {
          $scope.places = positions;
        } else {
          $scope.places = [positions];
        }
      }, function(error) {
        console.error(error);
      });
  }
}]);
