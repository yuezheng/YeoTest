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
    $scope.username = ''
    $scope.sendLoginRequest = () ->
      $scope.username = 'admin'
      $scope.password = 'zyzzy'
      authData =
          url: 'http://200.21.3.2:3303/'
          method: 'POST'
          headers:
            'Authorization': 'Basic dGVzdDp0ZXN0'
            'Content-Type': 'application/x-www-form-urlencoded'
          data:
            'username': $scope.username
            'password': $scope.password
          withCredentials: true
          crossDomain: true
      $http authData
        .success (data, status, headers) ->
            console.log(data)
