'use strict'

###*
 # @ngdoc function
 # @name Cross.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the Cross
###
angular.module('Cross.admin.instance')
  .controller 'InstanceCtr', ($scope, $http, $window, $q,
                              $state, $interval, $templateCache,
                              $compile, $animate) ->
    serverUrl = $window.$CROSS.settings.serverURL

    # Tabs at instance page
    $scope.tabs = [{
      title: 'Instances',
      template: 'one.tpl.html',
      enable: true
    }, {
      title: 'Imported',
      template: 'two.tpl.html'
      enable: true
    }, {
      title: 'Soft-deleted',
      template: 'three.tpl.html'
      enable: true
    }]

    # Function for tab switch
    $scope.currentTab = 'one.tpl.html'
    $scope.onClickTab = (tab) ->
      $scope.currentTab = tab.template
    $scope.isActiveTab = (tabUrl) ->
      return tabUrl == $scope.currentTab

    # Category for instance action
    $scope.batchActionEnableClass = 'btn-disable'
    $scope.vncLinkEnableClass = 'btn-disable'

    $scope.batchActions = [
      {action: 'reboot', verbose: 'Reboot'}
      {action: 'poweron', verbose: 'Power On'}
      {action: 'poweroff', verbose: 'Power Off'}
      {action: 'suspend', verbose: 'Suspend'}
      {action: 'wakeup', verbose: 'Wakeup'}
    ]
    $scope.mantanceActions = [
      {action: 'snapshot', verbose: 'Snapshot'}
      {action: 'resize', verbose: 'Resize'}
      {action: 'migrate', verbose: 'Migrate'}
    ]
    $scope.networkActions = [
      {action: 'attachIp', verbose: 'Attach IP'}
      {action: 'removeIP', verbose: 'Untach IP'}
    ]
    $scope.volumeActions = [
      {action: 'attachVolume', verbose: 'Attach Volume'}
      {action: 'removeVolume', verbose: 'Untach Volume'}
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

    $scope.columnDefs2 = [
      {
        field: "name",
        displayName: "Name",
        cellTemplate: '<div class="ngCellText enableClick" ng-click="detailShow(item.id)" data-toggle="tooltip" data-placement="top" title="{{item.name}}"><a ui-sref="admin./instance.detail./overview({ instanceId:item.id })" ng-bind="item[col.field]"></a></div>'
      }
      {
        field: "fixed",
        displayName: "FixedIP",
        cellTemplate: '<div class="ngCellText" ng-click="test(col)"><li ng-repeat="ip in item.fixed">{{ip}}</li></div>'
      }
      {
        field: "floating",
        displayName: "FloatingIP",
        cellTemplate: '<div class=ngCellText ng-click="test(row, col, $event)"><li ng-repeat="ip in item.floating">{{ip}}</li></div>'
      }
      {
        field: "hypervisor_hostname",
        displayName: "Host",
        cellTemplate: '<div class="ngCellText" ng-bind="item[col.field]" data-toggle="tooltip" data-placement="top" title="{{item.hypervisor_hostname}}"></div>'
      }
      {
        field: "project",
        displayName: "Project",
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
        displayName: "Status",
        cellTemplate: '<div class="ngCellText status" ng-class="item.labileStatus"><i></i>{{item.status}}</div>'
      }
    ]
    # --End--

    # Functions for handle event from action

    $scope.detailShow = (item) ->
      # Judge the height and width of detail area
      $scope.clickedInstance = item
      container = angular.element('.ui-view-container')
      $scope.detailHeight = $(window).height() - container.offset().top
      $scope.detailHeight -= 40
      # 80% width of parent ele
      $scope.detailWidth = container.width() *  0.78
      $scope.offsetLeft = container.width() * 0.22

    # Functions about interaction with server
    # --Start--

    # periodic get instance data which status is 'processing'
    $scope.getLabileData = (instanceId) ->
      freshData = $interval(() ->
        $cross.serverGet $http, $window, $q, instanceId, (instance) ->
          if instance.status not in $scope.labileStatus
            $interval.cancel(freshData)

          # if the instance.status turn to ok, update $scope.instances
          # and cancel fresh
          # else cuntiue freshData
          angular.forEach $scope.instances, (row, index) ->
            if row.id == instance.id
              $scope.instances[index] = instance
      , 3000)

    # Function for async list instances
    $scope.getPagedDataAsync = (pageSize, currentPage, callback) ->
      setTimeout(() ->
        currentPage = currentPage - 1
        dataQueryOpts =
          dataFrom: parseInt(pageSize) * parseInt(currentPage)
          dataTo: parseInt(pageSize) * parseInt(currentPage) + parseInt(pageSize)
        $cross.listDetailedServers $http, $window, $q, dataQueryOpts,
        (instances, total) ->
          $scope.setPagingData(instances, total)
          (callback && typeof(callback) == "function") && callback()
      , 100)

    # Delete selected servers
    $scope.deleteServer = () ->
      angular.forEach $scope.selectedServers, (item, index) ->
        instanceId = item.id
        $cross.serverDelete $http, $window, instanceId, (response) ->
          # TODO(ZhengYue): Add some tips for success or failed
          if response == 200
            # TODO(ZhengYue): Unify the tips for actions
            alert 'Success'

    $scope.serverAction = (action, group) ->
      actionName = $scope["#{group}Actions"][action].action
      angular.forEach $scope.selectedServers, (item, index) ->
        instanceId = item.id
        $cross.instanceAction actionName, $http, $window,
                              instanceId, (response) ->
          # TODO(ZhengYue): Add some tips for success or failed
          # If success update instance predic
          if response
            $scope.getLabileData(instanceId)

    # --End--

    # TODO(ZhengYue): Add loading status
    $scope.refresResource = (resource) ->
      tbody = angular.element('tbody.cross-data-table-body')
      tfoot = angular.element('tfoot.cross-data-table-foot')
      tbody.hide()
      tfoot.hide()
      loadCallback = () ->
        tbody.show()
        tfoot.show()
      $scope.getPagedDataAsync($scope.pagingOptions.pageSize,
                               $scope.pagingOptions.currentPage,
                               loadCallback)

