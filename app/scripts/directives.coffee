'use strict';

###*
 #
 #Directives
 #
###
angular.module("Cross.directives", [])
  .directive "sectorDirective", ->
    {
      restrict: "C"
      scope:
        val: "="
      link: ($scope, $ele) ->
        $scope.$watch 'val', (val) ->
          # If val data not ready, skip.
          if val == undefined
            return

          if $cross.animateSector and $ele.find("path").length > 0
            $inner = $ele.find(".sector-inner").eq(0)
            $outer = $ele.find(".sector-outer").eq(0)
            percent = val
            innerSize = $inner.width()
            outerSize = $outer.width()
            path = $ele.find("path")[0]
            $cross.animateSector path,
              centerX: outerSize / 2
              centerY: outerSize / 2
              startDegrees: 0
              endDegrees: parseInt(3.60 * percent)
              innerRadius: innerSize / 2
              outerRadius: outerSize / 2
              animate: true
    }
  .directive "hostTopologyDirective", ->
    {
      restrict: "C"
      scope:
        val: "="
      link: ($scope, $ele) ->
        $scope.$watch "val", (hostView) ->
          # If topology or hostView data not ready, skip.
          if not hostView
            return

          #options =
          #  type: "star"
          options = {}
          $cross.topology.drawHostView hostView, $ele, options
    }
  .directive "selectAllCheckbox", ->
    return {
      replace: true,
      restrict: 'E',
      scope: {
        checkboxes: '='
        allselected: '=allSelected'
        allclear: '=allClear'
      },
      template: '<input type="checkbox" ng-model="master" ng-change="masterChange(); selectChange()">',
      controller: ($scope, $element) ->
        $scope.masterChange = () ->
          if $scope.master
            angular.forEach $scope.checkboxes, (cb, index) ->
              cb.isSelected = true
          else
            angular.forEach $scope.checkboxes, (cb, index) ->
              cb.isSelected = false

        $scope.$watch('checkboxes', () ->
          allSet = true
          allClear = true
          angular.forEach $scope.checkboxes, (cb, index) ->
            if cb.isSelected
              allClear = false
            else
              allSet = false

          if $scope.allselected != undefined
            $scope.allselected = allSet
          if $scope.allclear != undefined
            $scope.allclear = allClear

          $element.prop 'indeterminate', false
          if allSet
            $scope.master = true
          else if allClear
            $scope.master = false
          else
            $scope.master = false
            $element.prop 'indeterminate', true
        , true)
    }
  .directive 'dynamic', ($compile) ->
    return {
      restrict: 'A',
      replace: true,
      scope: true,
      link: (scope, ele, attrs) ->
        scope.$watch attrs.dynamic, (html) ->
          ele.html(html)
          $compile(ele.contents())(scope)
    }
  .directive "customSort", () ->
    return {
      restrict: 'A',
      transclude: true,
      scope: {
        order: '=',
        sort: '='
      },
      template:
        ' <a ng-click="sort_by(order)" style="color: #55555;"><span ng-transclude></span><i ng-class="selectedCls(order)"></i> </a>'
      link: (scope) ->
        scope.sort_by = (newSortingOrder) ->
          sort = scope.sort
          if sort.sortingOrder == newSortingOrder
            sort.reverse = !sort.reverse

          sort.sortingOrder = newSortingOrder

        scope.selectedCls = (column) ->
          if column == scope.sort.sortingOrder
            return ('icon-chevron-' + ((scope.sort.reverse) ? 'down': 'up'))
          else
            return 'iocon-sort'
    }
