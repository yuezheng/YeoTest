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
              data:
                'username': $scope.username
                'password': $scope.password
          $http authData
            .success (data, status, headers) ->
              # TODO(zhengyue): Judge user's rule to choice redirect
              $state.go 'admin./overview'
      else
          alert "Input username and password"
