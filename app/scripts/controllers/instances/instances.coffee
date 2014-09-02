'use strict'

angular.module('Cross')
  .controller 'InstancesCtrl', ($scope, $http, $rootScope, $state) ->
    console.log "instances management"
    $scope.rowTemplate = '<div ng-style="{ cursor: row.cursor }" ng-repeat="col in renderedColumns" ng-class="col.colIndex()" class="ngCell {{col.cellClass}}"><div class="ngVerticalBar" ng-style="{height: rowHeight}" ng-class="{ ngVerticalBarVisible: !$last }">&nbsp;</div><div ng-cell></div></div>'
    $scope.myData = [
      {name: "Moroni", age: 50, host: 'test', status: 'active'}
      {name: "Moroni", age: 50, host: 'test', status: 'active'}
      {name: "Moroni", age: 50, host: 'test', status: 'active'}
      {name: "Moroni", age: 50, host: 'test', status: 'active'}
      {name: "Moroni", age: 50, host: 'test', status: 'active'}
      {name: "Tiancum", age: 43, host: 'test', status: 'active'}
      {name: "Jacob", age: 27, host: 'test', status: 'active'}
      {name: "Nephi", age: 29, host: 'test', status: 'active'}
      {name: "Nephi", age: 29, host: null, status: 'active'}
      {name: "Enos", age: 34, host: 'test', status: 'active'}]
    $scope.columnDefs = [
        {field: "name", displayName: "Name", cellTemplate: '<div ng-click="foo(col)" ng-bind="row.getProperty(col.field)"></div>'}
        {field: "age", displayName: "AGE"}
        {field: "status", displayName: "Status"}
        {field: "host", displayName: "Host", headerClass: "TestClass"}]
    $scope.selectedItem = []
    $scope.gridOptions = {
        data: 'myData',
        showSelectionCheckbox: true,
        columnDefs: 'columnDefs',
        enablePaging: true,
        showFooter: true,
        rowTemplate: $scope.rowTemplate,
        afterSelectionChange: (rowitem, event) ->
            $scope.selectedItems = $scope.gridOptions.selectedItems
            console.log $scope.selectedItems
        selectedItems: [],
        plugins: [new ngGridFlexibleHeightPlugin()]
    }
    console.log $scope.gridOptions

    $scope.foo = (item) ->
      if $scope.detail
        $scope.detail = false
      else
        $scope.detail = true

    $scope.toggle = true

    $scope.songs=['Sgt. Peppers Lonely Hearts Club Band','With a Little Help from My Friends','Lucy in the Sky with Diamonds','Getting Better' ,'Fixing a Hole','Shes Leaving Home','Being for the Benefit of Mr. Kite!' ,'Within You Without You','When Im Sixty-Four','Lovely Rita','Good Morning Good Morning','Sgt. Peppers Lonely Hearts Club Band (Reprise)','A Day in the Life']
