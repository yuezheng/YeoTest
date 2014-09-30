'use strict'

angular.module('Cross.admin.instance')
  .controller 'admin.instance.InstanceDetailCtr', ($scope, $http, $window,
                                                   $q, $stateParams, $state, $animate) ->

    $scope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
      $scope.currentId = $stateParams.instanceId

      if $scope.currentId
        $scope.detail_show = "detail_show"
      else
        $scope.detail_show = "detail_hide"

      $scope.detailShow()
      $window.onresize () ->
        $scope.detailShow()
      $scope.checkSelect()

      # Define the tab at instance detail
      $scope.instance_detail_tabs = [
        {
          name: 'Overview',
          url: 'admin.instance.instanceId.overview',
          available: true
        }
        {
          name: 'Log',
          url: 'admin.instance.instanceId.log',
          available: true
        }
        {
          name: 'Console',
          url: 'admin.instance.instanceId.console'
          available: true
        }
        {
          name: 'Monitor',
          url: 'admin.instance.instanceId.monitor'
          available: true
        }
      ]

      $scope.detailItem = {
        actions: _("Actions")
        info: _("Detail Info")
        flavorInfo: _("Flavor Info")
        item: {
          name: _("Name")
          id: _("Id")
          status: _("Status")
          host: _("Host")
          project: _("Project")
          fixed: _("FixedIP")
          floating: _("FloatingIP")
        }
        floavorItem: {
          cpu: _("CPU")
          ram: _("RAM")
          disk: _("Disk")
        }
      }

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
      {name: 'edit', verbose: _('Edit')},
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
            {name: 'resize', verbose: _('Resize')},
            {name: 'snapshot', verbose: _('Snapshot')},
            {name: 'migrate', verbose: _('Migrate')},
            {name: 'shutdown', verbose: _('Power Off')},
            {name: 'suspend', verbose: _('Suspend')},
            {name: 'reboot', verbose: _('Reboot')},
          ]
          for action in activeAction
            $scope.actionList.push action
        else if $scope.server_detail.status == 'SHUTOFF'
          shutoffAction = [
            {name: 'poweron', verbose: _('Power On')}
          ]
          for action in shutoffAction
            $scope.actionList.push action

        $scope.server_detail.status = _(server.status)
        $scope.actionList.push({name: 'delete', verbose: _('Delete')})

    $scope.panle_close = () ->
      $animate.enabled(true)
      $state.go 'admin.instance'
      $scope.detail_show = false

    $scope.detailShow = () ->
      container = angular.element('.ui-view-container')
      $scope.detailHeight = $(window).height() - container.offset().top
      $scope.detailHeight -= 40
      $scope.detailWidth = container.width() * 0.78
      $scope.offsetLeft = container.width() * 0.23
