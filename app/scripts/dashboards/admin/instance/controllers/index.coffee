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
    $scope.singleSelectedItem = {}
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

    # For checkbox select
    $scope.AllSelectedItems = false
    $scope.NoSelectedItems = true

    # For sort at table header
    $scope.sort = {
      sortingOrder: 'name',
      reverse: false
    }

    # For tabler footer and pagination or filter
    $scope.showFooter = true
    $scope.unFristPage = false
    $scope.unLastPage = false

    $scope.totalServerItems = 0
    $scope.pagingOptions = {
      pageSizes: [15, 25, 50]
      pageSize: 15
      currentPage: 1
    }
    $scope.filterOptions =
      filterText: '',
      useExternalFilter: true

    # TODO(ZhengYue): Make the total pages configurable and common
    __LIST_MAX__ = 5
    getPageCountList = (current_page, page_count) ->
      list = []
      if page_count <= __LIST_MAX__
        index = 0

        while index < page_count
          list[index] = index
          index++
      else
        start = current_page - Math.ceil(__LIST_MAX__ / 2)
        start = (if start < 0 then 0 else start)
        start = (if start + __LIST_MAX__ >= page_count\
                  then page_count - __LIST_MAX__ else start)
        index = 0

        while index < __LIST_MAX__
          list[index] = start + index
          index++
      list

    $scope.instances = [
    ]

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

    # Function for get paded instances and assign class for
    # element by status
    $scope.setPagingData = (pagedData, total) ->
      $scope.instances = pagedData
      $scope.totalServerItems = total
      # Compute the total pages
      $scope.pageCounts = Math.ceil(total / $scope.pagingOptions.pageSize)
      $scope.showPages = getPageCountList($scope.pagingOptions.currentPage,
                                          $scope.pageCounts)
      currentPage = $scope.pagingOptions.currentPage
      if currentPage == 1 and $scope.showPages.length > 1
        $scope.unFristPage = false
        $scope.unLastPage = true
      else if currentPage == 1 and $scope.showPages.length == 1
      else
        $scope.unFristPage = true
        if currentPage == $scope.pageCounts
          $scope.unLastPage = false

      for item in pagedData
        item.isSelected = false
        if item.status in $scope.labileStatus
          item.labileStatus = 'unknwon'
        else if item.status in $scope.shutdowStatus
          item.labileStatus = 'stoped'
        else if item.status in $scope.abnormalStatus
          item.labileStatus = 'abnormal'
        else
          item.labileStatus = 'active'
      if !$scope.$$phase
        $scope.$apply()

    # Set for instance table, binding event and assign data
    # TODO(ZhengYue): Separate template into views
    # TODO(ZhengYue): Make the common defined for data table
    $scope.columnDefs = [
      {
        field: "name",
        displayName: "Name",
        cellTemplate: '<div class="ngCellText enableClick" ng-click="detailShow(instance.id)" data-toggle="tooltip" data-placement="top" title="{{instance.name}}"><a ui-sref="admin./instance.detail./overview({ instanceId:instance.id })" ng-bind="instance[col.field]"></a></div>'
      }
      {
        field: "fixed",
        displayName: "FixedIP",
        cellTemplate: '<div class="ngCellText" ng-click="test(col)"><li ng-repeat="ip in instance.fixed">{{ip}}</li></div>'
      }
      {
        field: "floating",
        displayName: "FloatingIP",
        cellTemplate: '<div class=ngCellText ng-click="test(row, col, $event)"><li ng-repeat="ip in instance.floating">{{ip}}</li></div>'
      }
      {
        field: "hypervisor_hostname",
        displayName: "Host",
        cellTemplate: '<div class="ngCellText" ng-bind="instance[col.field]" data-toggle="tooltip" data-placement="top" title="{{instance.hypervisor_hostname}}"></div>'
      }
      {
        field: "project",
        displayName: "Project",
        cellTemplate: '<div ng-bind="instance[col.field]" class="ngCellText enableClick" data-toggle="tooltip" data-placement="top" title="{{instance.project}}"></div>'
      }
      {
        field: "vcpus",
        displayName: "CPU",
        cellTemplate: '<div ng-bind="instance[col.field]"></div>'
      }
      {
        field: "ram",
        displayName: "RAM (GB)",
        cellTemplate: '<div ng-bind="instance[col.field] | unitSwitch"></div>'
      }
      {
        field: "status",
        displayName: "Status",
        cellTemplate: '<div class="ngCellText status" ng-class="instance.labileStatus"><i></i>{{instance.status}}</div>'
      }
    ]
    # --End--

    # Functions for handle event from action

    $scope.selectedItems = []
    # TODO(ZhengYue): Add batch action enable/disable judge by status
    $scope.selectChange = () ->
      if $scope.selectedItems.length == 1
        $scope.NoSelectedItems = false
        $scope.batchActionEnableClass = 'btn-enable'
        $scope.vncLinkEnableClass = 'btn-enable'
        $scope.singleSelectedItem = $scope.selectedItems[0]
      else if $scope.selectedItems.length > 1
        $scope.NoSelectedItems = false
        $scope.batchActionEnableClass = 'btn-enable'
        $scope.vncLinkEnableClass = 'btn-disable'
        $scope.singleSelectedItem = {}
        $state.go 'admin./instance'
      else
        $scope.NoSelectedItems = true
        $scope.batchActionEnableClass = 'btn-disable'
        $scope.vncLinkEnableClass = 'btn-disable'
        $scope.singleSelectedItem = {}
        $state.go 'admin./instance'

    $scope.detailShow = (item) ->
      # Judge the height and width of detail area
      $scope.clickedInstance = item
      container = angular.element('.ui-view-container')
      $scope.detailHeight = $(window).height() - container.offset().top
      $scope.detailHeight -= 40
      # 80% width of parent ele
      $scope.detailWidth = container.width() *  0.78
      $scope.offsetLeft = container.width() * 0.22

    $scope.gotoPage = (index) ->
      # function for paging
      if typeof(index) is 'number'
        $scope.pagingOptions.currentPage = $scope.showPages[index] + 1
      else if index == 'next'
        $scope.pagingOptions.currentPage = \
            $scope.pagingOptions.currentPage + 1
      else if index == 'pre'
        $scope.pagingOptions.currentPage = \
            $scope.pagingOptions.currentPage - 1
      else if index == 'frist'
        $scope.pagingOptions.currentPage = 1
      else if index == 'last'
        $scope.pagingOptions.currentPage = $scope.pageCounts

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

    $scope.getPagedDataAsync($scope.pagingOptions.pageSize,
                             $scope.pagingOptions.currentPage)

    # Callback for instance list after paging change
    watchCallback = (newVal, oldVal) ->
      if newVal != oldVal and newVal.currentPage != oldVal.currentPage
        $scope.getPagedDataAsync $scope.pagingOptions.pageSize,
                                 $scope.pagingOptions.currentPage,
                                 $scope.filterOptions.filterText

    $scope.$watch('pagingOptions', watchCallback, true)

    # Callback after instance list change
    instanceCallback = (newVal, oldVal) ->
      if newVal != oldVal
        selectedItems = []
        for instance in newVal
          if instance.status in $scope.labileStatus
            $scope.getLabileData(instance.id)
          if instance.isSelected == true
            selectedItems.push instance
        $scope.selectedItems = selectedItems

    $scope.$watch('instances', instanceCallback, true)

    $scope.$watch('selectedItems', $scope.selectChange, true)

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
