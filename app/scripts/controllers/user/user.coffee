'use strict'

angular.module('Cross')
  .controller 'UserCtrl', ($scope, $http, $rootScope, $state) ->
    $scope.username = ""
    $scope.userId = ""
    reqParams =
      url: window.crossConfig.backendServer
      method: 'GET'
      headers:
        'Authorization': 'Basic dGVzdDp0ZXN0'
        'Content-Type': 'application/json'
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
        $http userParams
          .success (data, status, headers) ->
            $scope.user = data
      .error (error, status) ->
        # TODO(zhengyue): Add some tips
        console.log error

    $scope.logout = ->
      logoutParams =
        url: "#{$window.$CROSS.setting.serverUrl}logout"
        method: 'GET'
      $http logoutParams
        .success (data, status) ->
          $state.go 'login'
        .error (error, status) ->
          # TODO(zhengyue): Add some tips
          console.log error
