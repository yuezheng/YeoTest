'use strict'

angular.module('Cross.admin.instance')
  .controller 'InstanceDetailCtr', ($scope, $http, $window, $q, $stateParams, $state, $animate) ->

    $scope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
      # FIXME(ZhengYue): After data frist loaded, the link at
      # instance name losed the state param 'instanceId',
      # result to state can't trans.
      # Here is a remedial measure for this problem.
      # I think this problem's reason at rending template.
      if ! toParams.instanceId and $scope.clickedInstance
        toParams = {instanceId: $scope.clickedInstance}
        $state.go toState.name, toParams
      $scope.currentId = $stateParams.instanceId

      if $scope.currentId
        $scope.detail_show = "detail_show"
      else
        $scope.detail_show = "detail_hide"

      $scope.checkSelect()

      # Define the tab at instance detail
      $scope.instance_detail_tabs = [
        {
          name: 'Overview',
          url: 'admin./instance.detail./overview',
          available: true
        }
        {
          name: 'Log',
          url: 'admin./instance.detail./log',
          available: true
        }
        {
          name: 'Console',
          url: 'admin./instance.detail./console'
          available: true
        }
        {
          name: 'Monitor',
          url: 'admin./instance.detail./monitor'
          available: true
        }
      ]

      $scope.checkActive()
      $scope.getServer()


    $scope.checkActive = () ->
      for tab in $scope.instance_detail_tabs
        if tab.url == $state.current.name
          tab.active = 'active'
        else
          tab.active = ''

    $scope.checkSelect = () ->
      angular.forEach $scope.instances, (inst, index) ->
        if inst.isSelected == true and inst.id != $scope.currentId
          $scope.instances[index].isSelected = false
        if inst.id == $scope.currentId
          $scope.instances[index].isSelected = true

    # Judge tab of log is show/hide
    $scope.getServerLog = () ->
      $cross.serverLog $http, $window, $scope.currentId, 10, (log) ->
        if !log
          $scope.instance_detail_tabs[1].available = false

    $scope.UNKOWN_STATUS = [
      'ERROR'
    ]

    # Server action list
    $scope.actionList = [
      {name: 'edit', verbose: 'Edit'},
    ]

    # Get server detail info and judge action set for instance
    $scope.getServer = () ->
      $cross.serverGet $http, $window, $q, $scope.currentId, (server) ->
        $scope.server_detail = server
        if $scope.server_detail.status in $scope.UNKOWN_STATUS
          $scope.instance_detail_tabs[2].available = false
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
      $animate.enabled(true)
      $state.go 'admin./instance'
      $scope.detail_show = false
