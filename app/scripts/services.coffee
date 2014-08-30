'use strict'

###
 # @description
 # # The services module of Cross
 #
 # loginCheck service is used for user is login or not
###

angular.module('loginCheck', [])
  .factory '$logincheck' , ($http) ->
    return ($http) ->
      params =
        url: window.crossConfig.backendServer
        method: 'GET'
        headers:
          'Authorization': 'Basic dGVzdDp0ZXN0'
          'Content-Type': 'application/json'
        withCredentials: true
        crossDomain: true
      console.log 'Send request for judge user login'
      console.log window.crossConfig.backendServer
      $http params
        .success (data, status, headers) ->
          return true
        .error (error, status) ->
          if status is 401
            return false
