'use strict'

angular.module('Cross.admin.instance')
  .controller 'admin.instance.InstanceActionCtrl', ($scope, $http, $window) ->
    $scope.serverAction = (instanceId, action) ->
      $cross.instanceAction action, $http, $window, instanceId, callback
  .controller 'admin.instance.SnapshotCreatCtrl', ($scope, $http,
  $window, $q, $stateParams, $state) ->
    (new SnapshotCreateModal()).initial($scope,
      {$state: $state, $http: $http, instanceId: $stateParams.instId, $window: $window})
  .controller 'admin.instance.MigrateCtrl', ($scope, $http,
  $window, $q, $stateParams, $state) ->
    (new MigrateModal()).initial($scope, {
      $state: $state,
      $http: $http,
      instanceId: $stateParams.instId,
      $window: $window
    })
    # Get available host inject to fields
    params = {instanceId: $stateParams.instId}
    $cross.instanceAction 'avhosts', $http, $window, params, (hosts) ->
      $scope.modal.fields[0].default = [
        {text: hosts[0], value: hosts[0]}
      ]


class SnapshotCreateModal extends $cross.Modal
  title: "Create Snapshot"
  slug: "create_snapshot"

  fields: ->
    [{
      slug: "name"
      label: _ "Snapshot Name"
      tag: "input"
      restrictions:
        required: true
    }
    {
      slug: "username"
      label: _ "User Name"
      tag: "input"
      restrictions:
        required: false
    }
    {
      slug: "password"
      label: _ "Password"
      tag: "input"
      restrictions:
        required: false
    }]

  handle: ($scope, options) ->
    $scope.params = {
      name: $scope.form.name
      metadata: {}
    }
    $scope.params.instanceId = options.instanceId
    $cross.instanceAction 'snapshot', options.$http, options.$window, $scope.params, (status) ->
      if status == 200
        options.$state.go "admin.instance"
    return true

  close: ($scope, options) ->
    options.$state.go "admin.instance"

class MigrateModal extends $cross.Modal
  title: "Migrate"
  slug: "migrate"

  fields: ->
    [{
      slug: "host"
      label: _ "Destination Host"
      tag: "select"
      restrictions:
        required: true
    }]

  handle: ($scope, options) ->
    $scope.params = {
      disk_over_commit: true
      block_migration: false
      host: $scope.form.host
    }
    $scope.params.instanceId = options.instanceId
    $cross.instanceAction 'live-migrate', options.$http, options.$window, $scope.params, (status) ->
      if status == 200
        options.$state.go "admin.instance"
    return true

  close: ($scope, options) ->
    options.$state.go "admin.instance"
