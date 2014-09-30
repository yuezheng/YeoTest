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
    'Cross.settings',
    'Cross.admin',
    #'Cross.project',
    'Cross.menu',
    'Cross.directives',
    'Cross.filters',
    'ngAnimate',
    'ngResource',
    'ngRoute',
    'ui.router',
    'loginCheck',
    'ngSanitize',
    'ng.httpLoader',
    'ui.bootstrap'
  ])

app.config ($routeProvider, $httpProvider, $stateProvider,
            $urlRouterProvider, httpMethodInterceptorProvider) ->
  $httpProvider.defaults.useXDomain = true
  $httpProvider.defaults.withCredentials = true
  delete $httpProvider.defaults.headers.common['X-Requested-With']
  $urlRouterProvider.otherwise '/admin/overview'
  $stateProvider
    .state 'admin',
      templateUrl: 'views/main.html'
      controller: 'MainCtrl'
    .state 'login',
      url: '/login'
      templateUrl: 'views/login.html'
      controller: 'LoginCtrl'

  return

app.run ($rootScope, $state, $logincheck, $http, $location) ->
  $rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) ->
    $logincheck($http, $state, toState, toParams, event)
  return
