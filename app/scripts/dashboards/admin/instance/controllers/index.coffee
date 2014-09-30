'use strict'

###*
 # @ngdoc function
 # @name Cross.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the Cross
###
angular.module('Cross.admin.instance')
  .controller 'admin.instance.InstanceCtr', ($scope, $http, $window, $q,
                              $state, $interval, $templateCache,
                              $compile, $animate) ->
    serverUrl = $window.$CROSS.settings.serverURL

    # Tabs at instance page
    $scope.tabs = [{
      title: _('Instances'),
      template: 'one.tpl.html',
      enable: true
    }, {
      title: _('Imported'),
      template: 'two.tpl.html'
      enable: true
    }, {
      title: _('Soft-deleted'),
      template: 'three.tpl.html'
      enable: true
    }]

    # Function for tab switch
    $scope.currentTab = 'one.tpl.html'
    $scope.onClickTab = (tab) ->
      $scope.currentTab = tab.template
    $scope.isActiveTab = (tabUrl) ->
      return tabUrl == $scope.currentTab

    $scope.buttonGroup = {
      console: _("VNC Console")
      delete: _("Delete")
      more: _("More Action")
      refresh: _("Refresh")
      recover: _("Recover")
    }

    # Category for instance action
    $scope.batchActionEnableClass = 'btn-disable'
    $scope.vncLinkEnableClass = 'btn-disable'

    $scope.batchActions = [
      {action: 'reboot', verbose: _('Reboot')}
      {action: 'poweron', verbose: _('Power On')}
      {action: 'poweroff', verbose: _('Power Off')}
      {action: 'suspend', verbose: _('Suspend')}
      {action: 'wakeup', verbose: _('Wakeup')}
    ]
    $scope.mantanceActions = [
      {action: 'snapshot', verbose: _('Snapshot')}
      {action: 'resize', verbose: _('Resize')}
      {action: 'migrate', verbose: _('Migrate')}
    ]
    # NOTE(ZhengYue): network/volume actions not need for admin
    $scope.networkActions = [
      {action: 'attachIp', verbose: _('Attach IP')}
      {action: 'removeIP', verbose: _('Untach IP')}
    ]
    $scope.volumeActions = [
      {action: 'attachVolume', verbose: _('Attach Volume')}
      {action: 'removeVolume', verbose: _('Untach Volume')}
    ]

    # Variates for dataTable
    # --start--

    # For sort at table header
    $scope.sort = {
      sortingOrder: 'name',
      reverse: false
    }

    # For tabler footer and pagination or filter
    $scope.showFooter = true
    $scope.unFristPage = false
    $scope.unLastPage = false

    # Category for instance status
    $scope.labileStatus = [
      'BUILD'
      'MIGRATING'
      'HARD_REBOOT'
    ]
    $scope.abnormalStatus = [
      'ERROR'
    ]
    $scope.shutdowStatus = [
      'PAUSED'
      'SUSPENDED'
      'STOPPED'
      'SHUTOFF'
    ]

    $scope.columnDefs = [
      {
        field: "name",
        displayName: _("Name"),
        cellTemplate: '<div class="ngCellText enableClick" ng-click="detailShow(item.id)" data-toggle="tooltip" data-placement="top" title="{{item.name}}"><a ui-sref="admin.instance.instanceId.overview({ instanceId:item.id })" ng-bind="item[col.field]"></a></div>'
      }
      {
        field: "fixed",
        displayName: _("FixedIP"),
        cellTemplate: '<div class="ngCellText" ng-click="test(col)"><li ng-repeat="ip in item.fixed">{{ip}}</li></div>'
      }
      {
        field: "floating",
        displayName: _("FloatingIP"),
        cellTemplate: '<div class=ngCellText ng-click="test(row, col, $event)"><li ng-repeat="ip in item.floating">{{ip}}</li></div>'
      }
      {
        field: "hypervisor_hostname",
        displayName: _("Host"),
        cellTemplate: '<div class="ngCellText" ng-bind="item[col.field]" data-toggle="tooltip" data-placement="top" title="{{item.hypervisor_hostname}}"></div>'
      }
      {
        field: "project",
        displayName: _("Project"),
        cellTemplate: '<div ng-bind="item[col.field]" class="ngCellText enableClick" data-toggle="tooltip" data-placement="top" title="{{item.project}}"></div>'
      }
      {
        field: "vcpus",
        displayName: "CPU",
        cellTemplate: '<div ng-bind="item[col.field]"></div>'
      }
      {
        field: "ram",
        displayName: "RAM (GB)",
        cellTemplate: '<div ng-bind="item[col.field] | unitSwitch"></div>'
      }
      {
        field: "status",
        displayName: _("Status"),
        cellTemplate: '<div class="ngCellText status" ng-class="item.labileStatus"><i data-toggle="tooltip" data-placement="top" title="{{item.task_state}}"></i>{{item.status}}</div>'
      }
    ]
    # --End--
