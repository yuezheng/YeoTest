'use strict'

###
 # @description
 # # The services module of Cross
 #
 # loginCheck service is used for user is login or not
###

angular.module('loginCheck', [])
  .factory '$logincheck' , ($http, $state) ->
    return ($http, $state, next, event) ->
      params =
        url: window.crossConfig.backendServer
        method: 'GET'
      $http params
        .success (data, status, headers) ->
          event.preventDefault()
          $state.go next
          $cross.initialCentBox()
        .error (error, status) ->
          event.preventDefault()
          $state.go 'login'
