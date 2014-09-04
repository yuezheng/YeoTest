'use strict'

###
 # @description
 # # The services module of Cross
 #
 # loginCheck service is used for user is login or not
###

angular.module('loginCheck', [])
  .factory '$logincheck' , ($http, $state) ->
    return ($http, $state, next) ->
      params =
        url: window.crossConfig.backendServer
        method: 'GET'
        headers:
          'Authorization': 'Basic dGVzdDp0ZXN0'
          'Content-Type': 'application/json'
        withCredentials: true
        crossDomain: true
      $http params
        .success (data, status, headers) ->
          event.preventDefault()
          $state.go next
        .error (error, status) ->
          event.preventDefault()
          $state.go 'login'
