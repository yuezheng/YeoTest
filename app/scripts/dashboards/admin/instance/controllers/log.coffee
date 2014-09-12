'use strict'

angular.module('Cross.admin.instance')
  .controller 'InstanceLogCtr', ($scope, $http, $window, $q, $stateParams, $state) ->
    currentInstance = $stateParams.instanceId
    $scope.logLength = 35
    $cross.serverLog $http, $window, currentInstance, $scope.logLength, (data) ->
      console.log data
