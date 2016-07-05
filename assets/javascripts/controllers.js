
var App = angular.module('WeatherApp');

App.controller('WeatherWidgetController', function($scope, PlaceFinder) {
  this.isPopupOen = false;

  this.togglePopup = function() {
    this.isPopupOpen = !this.isPopupOpen
  };

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
});
