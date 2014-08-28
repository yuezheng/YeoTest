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
    'loginCheck'
  ])

app.config ($routeProvider, $httpProvider, $sceDelegateProvider) ->
  $httpProvider.defaults.useXDomain = true
  $httpProvider.defaults.withCredentials = true
  delete $httpProvider.defaults.headers.common['X-Requested-With']
  $routeProvider
    .when '/',
      templateUrl: 'views/main.html'
      controller: 'MainCtrl'
    .when '/login',
      templateUrl: 'views/login.html'
      controller: 'LoginCtrl'
    .otherwise
      redirectTo: '/'
  return

app.run ($rootScope, $location, $logincheck, $http) ->
  $rootScope.$on '$routeChangeStart', (event, next, current) ->
    if not $logincheck($http)
      event.preventDefault()
      $location.path '/login'
    else
      if next.originalPath == '/login'
        $location.path '/'
      else
        next
  return
