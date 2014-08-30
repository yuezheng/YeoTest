'use strict'

###*
 # @ngdoc function
 # @name Cross.controller:LoginCtrl
 # @description
 # # LoginCtrl
 # Controller of the Cross
###
angular.module('Cross')
  .controller 'LoginCtrl', ($scope, $http, $state) ->
    $scope.sendLoginRequest = () ->
      if $scope.username and $scope.password
          authData =
              url: window.crossConfig.backendServer + 'login'
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
                $state.go 'home.overview'
      else
          alert "Input username and password"
