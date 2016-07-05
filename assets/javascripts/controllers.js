
var App = angular.module('WeatherApp');

App.controller('WeatherWidgetController', function(PlaceFinder) {
  this.isPopupOen = false;

  this.togglePopup = function() {
    this.isPopupOpen = !this.isPopupOpen
  };

  this.findPlace = function(placeQuery) {
    PlaceFinder.find(placeQuery)
      .then(function(position) {
        console.log(position);
      }, function(error) {
        console.error(error);
      });
  }
});
