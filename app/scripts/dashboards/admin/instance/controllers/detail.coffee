'use strict'

angular.module('Cross.admin.instance')
  .controller 'InstanceDetailCtr', ($scope, $http, $window, $q, $stateParams, $state) ->
    $scope.instance_detail_tabs = [
      {
        name: 'Overview',
        url: 'admin./instance.detail./overview',
      }
      {
        name: 'Log',
        url: 'admin./instance.detail./log',
      }
      {
        name: 'Console',
        url: 'admin./instance.detail./console'
      }
      {
        name: 'Monitor',
        url: 'admin./instance.detail./monitor'
      }
    ]

    $scope.UNKOWN_STATUS = [
      'ERROR'
    ]

    $scope.actionList = [
      {name: 'edit', verbose: 'Edit'},
    ]

    currentInstance = $stateParams.instanceId

    $scope.checkActive = () ->
      for tab in $scope.instance_detail_tabs
        if tab.url == $state.current.name
          tab.active = 'active'
        else
          tab.active = ''

    $scope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
      $scope.checkActive()

    if currentInstance
      $scope.detail_show = "detail_show"
    else
      $scope.detail_show = "detail_hide"

    $cross.serverGet $http, $window, $q, currentInstance, (server) ->
      $scope.server_detail = server
      if $scope.server_detail.status in $scope.UNKOWN_STATUS
        $scope.actionList = [
          {name: 'edit', verbose: 'Edit'},
        ]
      else if $scope.server_detail.status == 'ACTIVE'
        activeAction = [
          {name: 'resize', verbose: 'Resize'},
          {name: 'snapshot', verbose: 'Snapshot'},
          {name: 'migrate', verbose: 'Migrate'},
          {name: 'shutdown', verbose: 'Shut Down'},
          {name: 'suspend', verbose: 'Suspend'},
          {name: 'reboot', verbose: 'Reboot'},
        ]
        for action in activeAction
          $scope.actionList.push action
      else if $scope.server_detail.status == 'SHUTOFF'
        shutoffAction = [
          {name: 'poweron', verbose: 'Power On'}
        ]
        for action in shutoffAction
          $scope.actionList.push action

      $scope.actionList.push({name: 'delete', verbose: 'Delete'})

    $scope.panle_close = () ->
      $state.go 'admin./instance'
      $scope.detail_show = false
