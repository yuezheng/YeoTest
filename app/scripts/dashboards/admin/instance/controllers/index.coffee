'use strict'

###*
 # @ngdoc function
 # @name Cross.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the Cross
###
angular.module('Cross.admin.instance')
  .controller 'InstanceCtr', ($scope, $http, $window, $q, $state, $timeout, $interval, $templateCache) ->
    serverUrl = $window.$CROSS.settings.serverURL
    $scope.tabs = [{
      title: 'Instances',
      template: 'one.tpl.html'
    }, {
      title: 'Imported',
      template: 'two.tpl.html'
    }, {
      title: 'Soft-deleted',
      template: 'three.tpl.html'
    }]


    $scope.unFristPage = false
    $scope.unLastPage = false
    $scope.currentTab = 'one.tpl.html'
    $scope.onClickTab = (tab) ->
      $scope.currentTab = tab.template

    $scope.isActiveTab = (tabUrl) ->
      return tabUrl == $scope.currentTab

    $scope.instances = [
    ]

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
        start = (if start + __LIST_MAX__ >= page_count then page_count - __LIST_MAX__ else start)
        index = 0

        while index < __LIST_MAX__
          list[index] = start + index
          index++
      list

    $scope.footerTemplate = $templateCache.get('ng-grid-footer')
    $scope.filterOptions =
      filterText: '',
      useExternalFilter: true

    $scope.batchActionEnableClass = 'btn-disable'
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
    $scope.totalServerItems = 0
    $scope.pagingOptions = {
      pageSizes: [15, 25, 50]
      pageSize: 15
      currentPage: 1
    }

    $scope.labileStatus = [
      'BUILD'
    ]

    $scope.setPagingData = (pagedData, total) ->
      $scope.instances = pagedData
      $scope.totalServerItems = total
      $scope.pageCounts = Math.ceil(total / $scope.pagingOptions.pageSize)
      $scope.showPages = getPageCountList($scope.pagingOptions.currentPage, $scope.pageCounts)
      if $scope.pagingOptions.currentPage == 1 and $scope.showPages.length > 1
        $scope.unFristPage = false
        $scope.unLastPage = true
      else
        $scope.unFristPage = true
        if $scope.pagingOptions.currentPage == $scope.pageCounts
          $scope.unLastPage = false
      for item in pagedData
        if item.status in $scope.labileStatus
          item.labileStatus = 'unknwon'
        else
          item.labileStatus = 'active'
      if !$scope.$$phase
        $scope.$apply()

    $scope.columnDefs = [
      {field: "name", displayName: "Name", cellTemplate: '<div class="ngCellText enableClick"><a ui-sref="admin./instance.detail./overview({ instanceId:row.entity.id })")" ng-click="foo(row.rowIndex)" ng-bind="row.getProperty(col.field)"></a></div>'}
      {field: "hypervisor_hostname", displayName: "Host"}
      {field: "project", displayName: "Project", cellTemplate: '<div ng-bind="row.getProperty(col.field)" class="ngCellText enableClick"></div>'}
      {field: "vcpus", displayName: "CPU", width: 120}
      {field: "ram", displayName: "RAM", width: 120}
      {field: "status", displayName: "Status", cellTemplate: '<div ng-bind="row.getProperty(col.field)" class="ngCellText" ng-class="row.entity.labileStatus"></div>', width: 130}
    ]

    $scope.getLabileData = (instanceId) ->
      freshData = $interval(() ->
        #TODO(ZhengYue): Get detail info by instance id
        $cross.serverGet $http, $window, instanceId, (instance) ->
          if instance.status in $scope.labileStatus
            console.log instance
          else
            $interval.cancel(freshData)
          # if instance.status is ok, update $scope.instances and cancel fresh
          # else cuntiue freshData
      , 3000)

    $scope.getPagedDataAsync = (pageSize, currentPage, searchText) ->
      setTimeout(() ->
        currentPage = currentPage - 1
        dataQueryOpts =
          dataFrom: parseInt(pageSize) * parseInt(currentPage)
          dataTo: parseInt(pageSize) * parseInt(currentPage) + parseInt(pageSize)
        $cross.listDetailedServers $http, $window, $q, dataQueryOpts, (instances, total) ->
          $scope.setPagingData(instances, total)
      , 100)

    $scope.getPagedDataAsync($scope.pagingOptions.pageSize, $scope.pagingOptions.currentPage)

    watchCallback = (newVal, oldVal) ->
      if newVal != oldVal and newVal.currentPage != oldVal.currentPage
        $scope.getPagedDataAsync $scope.pagingOptions.pageSize, $scope.pagingOptions.currentPage, $scope.filterOptions.filterText

    $scope.$watch('pagingOptions', watchCallback, true)

    instanceCallback = (newVal, oldVal) ->
      if newVal != oldVal
        for instance in newVal
          if instance.status in $scope.labileStatus
            $scope.getLabileData(instance.id)

    $scope.$watch('instances', instanceCallback, true)

    $scope.selectedIndex = []

    $scope.gridOptions = {
      data: 'instances',
      showSelectionCheckbox: true,
      enablePaging: true,
      selectWithCheckboxOnly: true,
      enableHighlighting: true,
      showFooter: true,
      columnDefs: 'columnDefs',
      afterSelectionChange: (rowitem, event) ->
        $scope.selectedItems = $scope.gridOptions.selectedItems
        if $scope.selectedItems.length > 0
          $scope.batchActionEnableClass = 'btn-enable'
        else
          $scope.batchActionEnableClass = 'btn-disable'
        if angular.isArray(rowitem)
          for row in rowitem
            if row.rowIndex not in $scope.selectedIndex
              $scope.selectedIndex.push row.rowIndex
        else if rowitem.rowIndex not in $scope.selectedIndex
          $scope.selectedIndex.push rowitem.rowIndex
      totalServerItems:'totalServerItems',
      selectedItems: [],
      pagingOptions: $scope.pagingOptions,
      filterOptions: $scope.filterOptions,
      plugins: [new $cross.ngGridFlexibleHeightPlugin()],
      footerTemplate: $scope.footerTemplate
    }

    $scope.foo = (item) ->
      for row in $scope.selectedIndex
        $scope.gridOptions.selectRow(row, false)
      $scope.gridOptions.selectRow(item, true)

      container = angular.element('.ui-view-container')
      $scope.detailHeight = $(window).height() - container.offset().top
      $scope.detailWidth = container.width() - 260

    $scope.deleteServer = () ->
      if $scope.selectedItems and $scope.selectedItems.length > 0
        for item in $scope.selectedItems
          instanceId = item.id
          $cross.serverDelete $http, $window, instanceId, (response) ->
            console.log response
            if response == 200
              alert 'Success'
      else
        alert "Choose a instance"

    $scope.serverAction = (action, group) ->
      console.log $scope[group + 'Actions'][action].action
      if $scope.selectedItems and $scope.selectedItems.length > 0
        for item in $scope.selectedItems
          instanceId = item.id
          $cross.serverDelete $http, $window, instanceId, (response) ->
            console.log response
      else
        alert "Choose a instance"

    $scope.gotoPage = (index) ->
      if typeof(index) is 'number'
        $scope.pagingOptions.currentPage = $scope.showPages[index] + 1
      else if index == 'next'
        $scope.pagingOptions.currentPage = $scope.pagingOptions.currentPage + 1
      else if index == 'pre'
        $scope.pagingOptions.currentPage = $scope.pagingOptions.currentPage - 1
