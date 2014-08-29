'use strict'

###*
 # @ngdoc overview
 # @name Cross
 # @description
 # # Cross
 #
 # Main module of the application.
###

app = angular.module('Cross', [
    'ngAnimate',
    'ngResource',
    'ngRoute',
    'ui.router',
    'loginCheck'
  ])

app.config ($routeProvider, $httpProvider, $stateProvider, $urlRouterProvider) ->
  $httpProvider.defaults.useXDomain = true
  $httpProvider.defaults.withCredentials = true
  delete $httpProvider.defaults.headers.common['X-Requested-With']
  $urlRouterProvider.otherwise("home")
  $stateProvider
    .state 'home',
      url: '/home'
      templateUrl: 'views/main.html'
      controller: 'MainCtrl'
    .state 'home.overview',
      url: '/overview'
      templateUrl: 'views/overview/overview.html'
      controller: 'OverviewCtrl'
    .state 'Users',
      url: '/users'
      templateUrl: 'views/UserManagement/users.html'
      controller: 'UserCtrl'
    .state 'login',
      url: '/login'
      templateUrl: 'views/login.html'
      controller: 'LoginCtrl'

  return

app.run ($rootScope, $state, $logincheck, $http) ->
  $rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) ->
    if not $logincheck($http)
      event.preventDefault()
      $state.go 'home'
    else
      if toState.url == '/login'
        event.preventDefault()
        $state.go 'home.overview'
      return
  return
