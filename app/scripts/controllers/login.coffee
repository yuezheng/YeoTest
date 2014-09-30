'use strict'

###*
 # @ngdoc function
 # @name Cross.controller:LoginCtrl
 # @description
 # # LoginCtrl
 # Controller of the Cross
###
angular.module("Cross")
  .controller "LoginCtrl", ($scope, $http, $state, $window) ->

    # Initial field.
    $scope.note =
      title: $window._ "Operation Management Platform"
      submit: $window._ "Login"
      username: $window._ "User Name"
      password: $window._ "Password"

    $scope.validator =
      note: $window._ "User Name could not be empty!"
      isInvalid: false

    $scope.user =
      username: ""
      password: ""

    $scope.sendLoginRequest = ->
      if $scope.user.password == ""
        $scope.validator.note = $window._ "Password could not be empty!"
        $scope.validator.isInvalid = true
      else if $scope.user.username == ""
        $scope.validator.note = $window._ "User name could not be empty!"
        $scope.validator.isInvalid = true
      else
        $scope.validator.isInvalid = false
        authData =
            url: "#{$window.$CROSS.settings.serverURL}/login"
            method: 'POST'
            headers:
              'Authorization': 'Basic dGVzdDp0ZXN0'
              'Content-Type': 'application/json'
            data:
              'username': $scope.user.username
              'password': $scope.user.password

        angular.element(".loading-container").show()
        angular.element("#login_submit").attr("disabled", true)
        $http authData
          .success (data, status, headers) ->
            # TODO(zhengyue): Judge user's rule to choice redirect
            angular.element(".loading-container").hide()
            angular.element("#login_submit").removeAttr("disabled")
            $state.go 'admin.overview'
          .error (err, status) ->
            angular.element(".loading-container").hide()
            angular.element("#login_submit").removeAttr("disabled")
            $scope.validator.isInvalid = true
            if status == 401
              message = "Username and password are not match!"
              $scope.validator.note = $window._ message
            else if status < 500
              message = "Failed to submit user data!"
              $scope.validator.note = $window._ message
            else if status >= 500
              message = "Server error!"
              $scope.validator.note = $window._ message
