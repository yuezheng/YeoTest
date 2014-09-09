'use strict'

###*
 # @ngdoc function
 # @name Cross.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the Cross
###
angular.module('Cross.admin.instance')
  .controller 'InstanceCtr', ($scope, $http, $window, $q, $state, $timeout, $interval) ->
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
    $scope.currentTab = 'one.tpl.html'
    $scope.onClickTab = (tab) ->
      $scope.currentTab = tab.template

    $scope.isActiveTab = (tabUrl) ->
      return tabUrl == $scope.currentTab

    $scope.instances = [
    ]
    
    $scope.filterOptions =
      filterText: '',
      useExternalFilter: true

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
      for item in pagedData
        if item.status in $scope.labileStatus
          item.labileStatus = 'unknwon'
        else
          item.labileStatus = 'active'
      if !$scope.$$phase
        $scope.$apply()

    $scope.columnDefs = [
      {field: "name", displayName: "Name", cellTemplate: '<div class="ngCellText enableClick"><a ui-sref="admin./instance.detail({ instanceId:row.entity.id })")" ng-click="foo(row.rowIndex)" ng-bind="row.getProperty(col.field)"></a></div>'}
      {field: "hypervisor_hostname", displayName: "Host"}
      {field: "project", displayName: "Project", cellTemplate: '<div ng-bind="row.getProperty(col.field)" class="ngCellText enableClick"></div>'}
      {field: "vcpus", displayName: "CPU"}
      {field: "ram", displayName: "RAM"}
      {field: "status", displayName: "Status", cellTemplate: '<div ng-bind="row.getProperty(col.field)" class="ngCellText" ng-class="row.entity.labileStatus"></div>'}
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
      plugins: [new $cross.ngGridFlexibleHeightPlugin()]
    }

    $scope.foo = (item) ->
      for row in $scope.selectedIndex
        $scope.gridOptions.selectRow(row, false)
      $scope.gridOptions.selectRow(item, true)

    $scope.deleteServer = () ->
      if $scope.selectedItems and $scope.selectedItems.length > 0
        for item in $scope.selectedItems
          console.log 'ss'
          # TODO(ZhengYue): Delete server
      else
        alert "Choose a instance"
