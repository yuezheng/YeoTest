'use strict'

###*
 # @ngdoc function
 # @name Cross.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the Cross
###
angular.module('Cross')
  .controller 'MainCtrl', ($scope, $http, $rootScope) ->
    checkSession = () ->
      params =
        url: 'http://200.21.3.2:4000/projects/5/2'
        method: 'GET'
        headers:
          'Authorization': 'Basic dGVzdDp0ZXN0'
          'Content-Type': 'application/json'
        withCredentials: true
        crossDomain: true
      $http params
        .success (data, status, headers) ->
            console.log data
        .error (error, status) ->
            if status is 401
              location.href = "#/login"

    checkSession()
