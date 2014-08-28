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
        url: 'http://200.21.3.2:4000/'
        method: 'GET'
        headers:
          'Authorization': 'Basic dGVzdDp0ZXN0'
          'Content-Type': 'application/json'
        withCredentials: true
        crossDomain: true
      $http params
        .success (data, status, headers) ->
          return true
        .error (error, status) ->
          if status is 401
            return false
