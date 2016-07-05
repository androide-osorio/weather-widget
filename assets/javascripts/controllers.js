
var App = angular.module('WeatherApp', []);

App.controller('WeatherWidgetController', function() {
  this.isPopupOen = false;

  this.togglePopup = function() {
    this.isPopupOpen = !this.isPopupOpen
  };
});
