'use strict'

###*
 # @ngdoc function
 # @name Cross.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the Cross
###
angular.module('Cross.admin.instance')
  .controller 'InstanceCtr', ($scope, $http, $window, $q) ->
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

    $scope.setPagingData = (pagedData, total) ->
      $scope.instances = pagedData
      $scope.totalServerItems = total
      if !$scope.$$phase
        $scope.$apply()

    largeLoad = [
        {"name": "Moroni", "allowance": 50, "paid": true},
        {"name": "Moroni", "allowance": 50,  "paid": true},
        {"name": "Tiancum", "allowance": 53,  "paid": false}]

    $scope.columnDefs = [
      {field: "name", displayName: "Name", cellTemplate: '<div ng-click="foo(row.entity.id)" class="ngCellText enableClick"><a ui-sref="admin./instance.detail({ instanceId:row.entity.id })" ng-bind="row.getProperty(col.field)"></a></div>'}
      {field: "hypervisor_hostname", displayName: "Host"}
      {field: "project", displayName: "Project", cellTemplate: '<div ng-bind="row.getProperty(col.field)" class="ngCellText enableClick"></div>'}
      {field: "vcpus", displayName: "CPU"}
      {field: "ram", displayName: "RAM"}
      {field: "status", displayName: "Status"}
    ]

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
      selectedItems: [],
      totalServerItems:'totalServerItems',
      pagingOptions: $scope.pagingOptions,
      filterOptions: $scope.filterOptions,
      plugins: [new $cross.ngGridFlexibleHeightPlugin()]
    }

    $scope.foo = (item) ->
      console.log(item)
