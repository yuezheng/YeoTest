'use strict'

instanceAttrs = ['id', 'name', 'status', 'OS-EXT-SRV-ATTR:hypervisor_hostname'
                 'flavor', 'tenant_id', 'user_id']

###
Simple wrapper around nova server API
###
class $cross.Server extends $cross.APIResourceWrapper
  constructor: (instance, attrs) ->
    super instance, attrs

  getFullObj: (instance, $http) ->
    console.log instance

###
Simple wrapper around nova flavor API
###
class $cross.Flavor extends $cross.APIResourceWrapper
  constructor: (flavor, attrs) ->
    super flavor, attrs

###
List server that contain base instance info.
###
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

###
List server that contain info base instance and extended.
###
# TODO(ZhengYue): Modify function name
$cross.listDetailedServers = ($http, $window, $q, query, callback) ->
  serverUrl = $window.crossConfig.backendServer
  limitFrom = query.dataFrom || 0
  limitTo = query.dataTo || 20
  if limitFrom != 0
    limitFrom += 1
  instancesParams = "servers?limit_from=#{limitFrom}&limit_to=#{limitTo}"
  instances = $http.get(serverUrl + instancesParams)
    .then (response) ->
      return response.data
  flavors = $http.get(serverUrl + 'os-flavors')
    .then (response) ->
      return response.data
  projects = $http.get(serverUrl + 'projects/5/5')
    .then (response) ->
      return response.data
  # TODO(ZhengYue): The user list interface not implement

  # Ensure that multiple requests all return
  # TODO(ZhengYue): Error handler
  $q.all([instances, flavors, projects])
    .then (values) ->
      flavorMap = {}
      projectsMap = {}
      # NOTE(ZhengYue): Package flavor/project/user info into
      # a Object which indexed with id.
      for flavor in values[1].data
        flavorObj = new $cross.Flavor(flavor, ['name', 'id', 'vcpus', 'ram', 'disk'])
        flavorMap[flavor.id] = flavorObj.getObject(flavorObj)

      for project in values[2].data
        projectObj = new $cross.Project(project, ['name'])
        projectsMap[project.id] = projectObj.getObject(projectObj)

      serverList = []

      # Inject detail info(flavor/project/user) into server obj.
      for instance in values[0].data
        server = new $cross.Server(instance, instanceAttrs)
        serverObj = server.getObject(server)
        flavorId = JSON.parse(serverObj.flavor).id
        serverFlavor = flavorMap[flavorId]
        serverObj.vcpus = serverFlavor['vcpus']
        serverObj.ram = serverFlavor['ram']
        serverObj.project = projectsMap[serverObj.tenant_id]['name']
        serverList.push serverObj

      callback serverList, values[0].total

###
Get a server.
###
$cross.serverGet = ($http, $window, instanceId, callback) ->
  requestData =
    url: $window.crossConfig.backendServer + 'servers/' + instanceId
    method: 'GET'

  $http requestData
    .success (instance, status, headers) ->
      server = new $cross.Server(instance, instanceAttrs)
      server_detail = server.getObject(server)
      callback server_detail

###
Get a server.
###
$cross.serverDelete = ($http, $window, instanceId, callback) ->
  requestData =
    url: $window.crossConfig.backendServer + 'servers/' + instanceId
    method: 'DELETE'

  $http requestData
    .success (instance, status, headers) ->
      server = new $cross.Server(instance, instanceAttrs)
      server_detail = server.getObject(server)
      callback server_detail
