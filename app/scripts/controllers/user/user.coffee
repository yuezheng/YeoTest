'use strict'

angular.module('Cross')
  .controller 'UserCtrl', ($scope, $http, $rootScope, $state) ->
    console.log "User management"
    $scope.username = ""
    $scope.userId = ""
    reqParams =
      url: window.crossConfig.backendServer
      method: 'GET'
      headers:
        'Authorization': 'Basic dGVzdDp0ZXN0'
        'Content-Type': 'application/json'
    console.log 'Request user info'
    $http reqParams
      .success (data, status, headers) ->
        $scope.username = data.user.name
        $scope.userId = data.user.id
        userParams =
          url: window.crossConfig.backendServer + "users/" + $scope.userId
          method: 'GET'
          headers:
            'Authorization': 'Basic dGVzdDp0ZXN0'
            'Content-Type': 'application/json'
        console.log "Get user detail"
        $http userParams
          .success (data, status, headers) ->
            console.log data
      .error (error, status) ->
        console.log error

    $scope.logout = () ->
      console.log 'Log out'
      logoutParams =
        url: window.crossConfig.backendServer + 'logout'
        method: 'GET'
      $http logoutParams
        .success (data, status) ->
          $state.go 'login'
        .error (error, status) ->
          console.log error
