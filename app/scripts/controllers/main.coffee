'use strict'

###*
 # @ngdoc function
 # @name testApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the testApp
###
angular.module('testApp')
  .controller 'MainCtrl', ($scope, $http) ->
    checkSession = () ->
      params =
          url: 'http://200.21.3.2:3303/'
        method: 'GET'
        headers:
          'Authorization': 'Basic dGVzdDp0ZXN0'
          'Content-Type': 'application/json'
        withCredentials: true
        crossDomain: true
      $http params
        .success (data, status, headers) ->
            console.log data

    checkSession()
