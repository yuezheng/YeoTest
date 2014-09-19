'use strict'

angular.module('Cross.admin.instance')
  .controller 'InstanceLogCtr', ($scope, $http, $window, $q, $stateParams, $state) ->
    currentInstance = $stateParams.instanceId
    # TODO(ZhengYue): Add feature for query log by length
    $scope.logLength = 35
    $cross.serverLog $http, $window, currentInstance, $scope.logLength, (data) ->
      # TODO(ZhengYue): Add error handler
      $scope.log = data
