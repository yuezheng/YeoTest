'use strict'

###*
 # @ngdoc function
 # @name Cross.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the Cross
###
angular.module('Cross.admin.info')
  .controller 'InfoCtr', ($scope, $http, $rootScope) ->
    console.log 'instance'
