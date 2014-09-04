'use strict'

###*
 # @ngdoc overview
 # @name Cross.menu
 # @description
 # # Cross
 #
 # Main module of the application.
###

app = angular.module('Cross.menu', [])

app.run ($rootScope, $http, $window) ->
  # initial left nav bar for cross.
  if 'menu' not in $window.$CROSS.settings.dashboards
    return
  dashboards = $window.$CROSS.dashboards || {}
  defaultView = $window.$CROSS.settings.defaultView
  view = $window.$CROSS.view || defaultView
  viewDashboads = dashboards[view] || []
  $window.$CROSS.dashboards = undefined
  $rootScope.$dashboards = viewDashboads
  $rootScope.$view = view
  return
