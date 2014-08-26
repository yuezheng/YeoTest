'use strict'

###*
 # @ngdoc function
 # @name testApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the testApp
###
angular.module('testApp')
  .controller 'LoginCtrl', ($scope, $http) ->
    $scope.sendLoginRequest = () ->
      if $scope.username and $scope.password
          authData =
              url: 'http://200.21.3.2:3303/login'
              method: 'POST'
              headers:
                'Authorization': 'Basic dGVzdDp0ZXN0'
                'Content-Type': 'application/json'
              data:
                'username': $scope.username
                'password': $scope.password
              withCredentials: true
              crossDomain: true
          $http authData
            .success (data, status, headers) ->
                console.log data
      else
          ervice_cataloglert "Input username and password"
