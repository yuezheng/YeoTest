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

    $scope.projects = [
    ]

    $scope.columnDefs = [
      {field: "name", displayName: "Name"}
      {field: "hypervisor_hostname", displayName: "Host"}
      {field: "project", displayName: "Project"}
      {field: "vcpus", displayName: "CPU"}
      {field: "ram", displayName: "RAM"}
      {field: "status", displayName: "Status"}
    ]
    $scope.gridOptions = {
      data: 'projects',
      showSelectionCheckbox: true,
      enablePaging: true,
      showFooter: true,
      columnDefs: 'columnDefs',
      rowTemplate: $scope.rowTemplate,
      afterSelectionChange: (rowitem, event) ->
        $scope.selectedItems = $scope.gridOptions.selectedItems
        console.log $scope.selectedItems
      selectedItems: [],
    }
    $cross.listFullServers $http, $window, $q, (instances) ->
      $scope.projects = instances
      console.log instances
      $scope.selectedItem = []
      $scope.gridOptions = {
          data: 'projects',
          showSelectionCheckbox: true,
          enablePaging: true,
          showFooter: true,
          columnDefs: 'columnDefs',
          rowTemplate: $scope.rowTemplate,
          afterSelectionChange: (rowitem, event) ->
            $scope.selectedItems = $scope.gridOptions.selectedItems
            console.log $scope.selectedItems
          selectedItems: [],
      }
