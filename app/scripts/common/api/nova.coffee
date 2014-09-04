'use strict'

instanceAttrs = ['name', 'status', 'OS-EXT-SRV-ATTR:hypervisor_hostname'
                 'flavor', 'tenant_id', 'user_id']

class $cross.Server extends $cross.APIResourceWrapper
  constructor: (instance, attrs) ->
    super instance, attrs

  getFullObj: (instance, $http) ->
    console.log instance

class $cross.Flavor extends $cross.APIResourceWrapper
  constructor: (flavor, attrs) ->
    super flavor, attrs

$cross.listServers = ($http, $window, callback) ->
  requestData =
    url: $window.crossConfig.backendServer + 'servers'
    method: 'GET'

  $http requestData
    .success (instances, status, headers) ->
      serverList = []
      for instance in instances.data
        server = new $cross.Server(instance, instanceAttrs)
        serverList.push server.getObject(server)
      callback serverList

$cross.listFullServers = ($http, $window, $q, callback) ->
  # TODO(ZhengYue): Add pagenation
  serverUrl = $window.crossConfig.backendServer
  instances = $http.get(serverUrl + 'servers?limit_from=0&limit_to=20')
    .then (response) ->
      return response.data
  flavors = $http.get(serverUrl + 'os-flavors')
    .then (response) ->
      return response.data
  projects = $http.get(serverUrl + 'projects/5/5')
    .then (response) ->
      return response.data
  # TODO(ZhengYue): The user list interface not implement
  $q.all([instances, flavors, projects])
    .then (values) ->
      flavorMap = {}
      projectsMap = {}
      for flavor in values[1].data
        flavorObj = new $cross.Flavor(flavor, ['name', 'id', 'vcpus', 'ram', 'disk'])
        flavorMap[flavor.id] = flavorObj.getObject(flavorObj)

      for project in values[2].data
        projectObj = new $cross.Project(project, ['name'])
        projectsMap[project.id] = projectObj.getObject(projectObj)

      serverList = []
      for instance in values[0].data
        server = new $cross.Server(instance, instanceAttrs)
        serverObj = server.getObject(server)
        flavorId = JSON.parse(serverObj.flavor).id
        serverFlavor = flavorMap[flavorId]
        serverObj.vcpus = serverFlavor['vcpus']
        serverObj.ram = serverFlavor['ram']
        serverObj.project = projectsMap[serverObj.tenant_id]['name']

        serverList.push serverObj

      callback serverList
