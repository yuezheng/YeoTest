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

    console.log $scope.instance_detail_tabs

    currentInstance = $stateParams.instanceId
    if currentInstance
      $scope.detail_show = true
    else
      $scope.detail_show = false

    $cross.serverGet($http, $window, currentInstance, (server) ->
      $scope.server_detail = server
      if $scope.server_detail.status in $scope.UNKOWN_STATUS
        $scope.action_list = [
          'delete'
        ]
        console.log $scope.action_list
      console.log $scope.server_detail
    )

    $scope.panle_close = () ->
      $state.go 'admin./instance'
      $scope.detail_show = false
