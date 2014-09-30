'use strict'

angular.module('Cross.menu')
  .controller 'navbarCtrl', ($scope, $state) ->
    $scope.currentPanelSlug = ''
    $scope.currentDashboardSlug = ''
    $scope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
      currentState = toState.name
      splitedName = currentState.split('.')
      if splitedName.length >= 2
        if '/' in splitedName[1]
          $scope.currentPanelSlug = splitedName[1].substr 1
        else
          $scope.currentPanelSlug = splitedName[1]

      dashboards = $scope.$parent.$dashboards
      angular.forEach dashboards, (dashboard, index) ->
        angular.forEach dashboard.panels, (panel, index) ->
          if panel.slug == $scope.currentPanelSlug
            $scope.currentDashboardSlug = dashboard.slug
