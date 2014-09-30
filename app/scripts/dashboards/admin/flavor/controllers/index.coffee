'use strict'

###*
 # @ngdoc function
 # @name Cross.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the Cross
###
angular.module('Cross.admin.flavor')
  .controller 'admin.flavor.FlavorCtr', ($scope, $http, $window) ->
    serverUrl = $window.$CROSS.settings.serverURL
    $scope.note =
      create: $window._ "create"
      test: $window._ "test"
      update: $window._ "update"
      resize: $window._ "resize"

  .controller 'admin.flavor.FlavorCreateCtr', ($scope, $http, $window) ->
    (new FlavorCreateModal()).initial($scope)
  .controller 'admin.flavor.FlavorTestCtr', ($scope, $http, $window) ->
    (new FlavorCreateModal()).initial($scope)
  .controller 'admin.flavor.FlavorUpdateCtr', ($scope, $http, $window) ->
    (new FlavorUpdateModal()).initial($scope)
    $scope.form['step1']['test'] = [0]
  .controller 'admin.flavor.FlavorResizeCtr', ($scope, $http, $window) ->
    (new FlavorResizeModal()).initial($scope)


class FlavorCreateModal extends $cross.Modal
  title: "Create Modal"
  slug: "create_flavor"

  fields: ->
    [{
      slug: "name"
      label: _ "Name"
      tag: "input"
      restrictions:
        ip: true
        required: true
    }, {
      slug: "test"
      label: _ "Test"
      tag: "input"
      type: 'checkbox-list'
      default: [{
        text: _ "Test 1"
        value: 0
      },{
        text: _ "Test 2"
        value: 1
      }]
    }, {
      slug: "password"
      label: _ "Password"
      tag: "input"
      type: 'password'
      restrictions:
        len: [3, 16]
        regex: [/[a-z]|[A-Z]/, _("cccccc")]
    }, {
      slug: "gender"
      label: _ "Gender"
      tag: "select"
      default: [{
        text: _ "Male"
        group: "Test A"
        value: 0
      }, {
        text: _ "Female1"
        group: "Test A"
        value: 1
      }, {
        text: _ "Female"
        value: 2
      }]
    }, {
      slug: "content"
      label: _ "Content"
      tag: "textarea"
      restrictions:
        cidr: true
    }]

  handle: ($scope, options)->
    return true

class FlavorUpdateModal extends $cross.Modal
  title: "Update Modal"
  slug: "update_flavor"
  single: false
  steps: ['step1', 'step2', 'step3']

  step_step1: ->
    name: "Basic info"
    fields: [{
      slug: "name"
      label: _ "Name"
      tag: "input"
      restrictions:
        ip: true
    }, {
      slug: "password"
      label: _ "Password"
      tag: "input"
      type: 'password'
      restrictions:
        length: [3, 16]
        regex: [/[a-z]|[A-Z]/, _("cccccc")]
    }, {
      slug: "test"
      label: _ "Test"
      tag: "input"
      type: 'checkbox-list'
      default: [{
        text: _ "Test 1"
        value: 0
      },{
        text: _ "Test 2"
        value: 1
      }]
    }, {
      slug: "gender"
      label: _ "Gender"
      tag: "select"
      default: [{
        text: _ "Male"
        value: 0
      }, {
        text: _ "Female"
        value: 1
      }]
    }, {
      slug: "content"
      label: _ "Content"
      tag: "textarea"
      restrictions:
        cidr: true
    }]

  step_step2: ->
    name: "User info"
    fields: [{
      slug: "name"
      label: _ "Name"
      tag: "input"
    }, {
      slug: "password"
      label: _ "Password"
      tag: "input"
      type: 'password'
    }, {
      slug: "gender"
      label: _ "Gender"
      tag: "select"
      default: [{
        text: _ "Male"
        value: 0
      }, {
        text: _ "Female"
        value: 1
      }]
    }, {
      slug: "content"
      label: _ "Content"
      tag: "textarea"
    }]

  step_step3: ->
    name: "Quota info"
    fields: [{
      slug: "name"
      label: _ "Name"
      tag: "input"
    }, {
      slug: "password"
      label: _ "Password"
      tag: "input"
      type: 'password'
    }, {
      slug: "gender"
      label: _ "Gender"
      tag: "select"
      default: [{
        text: _ "Male"
        value: 0
      }, {
        text: _ "Female"
        value: 1
      }]
    }, {
      slug: "content"
      label: _ "Content"
      tag: "textarea"
    }]

class FlavorResizeModal extends $cross.Modal
  title: "Resize Modal"
  slug: "resize_flavor"
  single: false
  steps: ['step1', 'step2']
  parallel: true

  step_step1: ->
    name: "Basic info"
    fields: [{
      slug: "name"
      label: _ "Name"
      tag: "input"
      restrictions:
        ip: true
    }, {
      slug: "password"
      label: _ "Password"
      tag: "input"
      type: 'password'
      restrictions:
        length: [3, 16]
        regex: [/[a-z]|[A-Z]/, _("cccccc")]
    }, {
      slug: "test"
      label: _ "Test"
      tag: "input"
      type: 'checkbox-list'
      default: [{
        text: _ "Test 1"
        value: 0
      },{
        text: _ "Test 2"
        value: 1
      }]
    }, {
      slug: "gender"
      label: _ "Gender"
      tag: "select"
      default: [{
        text: _ "Male"
        value: 0
      }, {
        text: _ "Female"
        value: 1
      }]
    }, {
      slug: "content"
      label: _ "Content"
      tag: "textarea"
      restrictions:
        cidr: true
    }]

  step_step2: ->
    name: "User info"
    fields: [{
      slug: "name"
      label: _ "Name"
      tag: "input"
    }, {
      slug: "password"
      label: _ "Password"
      tag: "input"
      type: 'password'
    }, {
      slug: "gender"
      label: _ "Gender"
      tag: "select"
      default: [{
        text: _ "Male"
        value: 0
      }, {
        text: _ "Female"
        value: 1
      }]
    }, {
      slug: "content"
      label: _ "Content"
      tag: "textarea"
    }]
