'use strict'

angular.module('Cross.admin.instance')
  .controller 'InstanceDetailCtr', ($scope, $http, $window, $q, $stateParams, $state) ->
    $scope.instance_detail_tabs = [
      'Overview'
      'Log'
      'Console'
      'Monitor'
    ]

    $scope.UNKOWN_STATUS = [
      'ERROR'
    ]

    $scope.action_list = []

    currentInstance = $stateParams.instanceId
    if currentInstance
      $scope.detail_show = "detail_show"
    else
      $scope.detail_show = "detail_hide"

    $cross.serverGet($http, $window, currentInstance, (server) ->
      $scope.server_detail = server
      if $scope.server_detail.status in $scope.UNKOWN_STATUS
        $scope.action_list = [
          'delete'
        ]
    )

    $scope.panle_close = () ->
      $state.go 'admin./instance'
      $scope.detail_show = false
