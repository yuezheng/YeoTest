'use strict'

angular.module('Cross')
  .controller 'InstancesCtrl', ($scope, $http, $rootScope, $state) ->
    console.log "instances management"
    $scope.myData = [
      {name: "Moroni", age: 50}
      {name: "Tiancum", age: 43}
      {name: "Jacob", age: 27}
      {name: "Nephi", age: 29}
      {name: "Enos", age: 34}]
    $scope.columnDefs = [
        {field: "name", displayName: "Name", cellTemplate: '<div ng-click="foo(col)" ng-bind="row.getProperty(col.field)"></div>'}
        {field: "age", displayName: "AGE"}]
    $scope.selectedItem = []
    $scope.gridOptions = {
        data: 'myData',
        showSelectionCheckbox: true,
        columnDefs: 'columnDefs',
        enablePaging: true,
        showFooter: true,
        afterSelectionChange: (rowitem, event) ->
            $scope.selectedItems = $scope.gridOptions.selectedItems
            console.log $scope.selectedItems
        selectedItems: []
    }
    console.log $scope.gridOptions

    $scope.foo = (item) ->
      console.log item
