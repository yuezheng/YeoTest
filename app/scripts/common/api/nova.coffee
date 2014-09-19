'use strict'

instanceAttrs = ['id', 'name', 'status', 'OS-EXT-SRV-ATTR:hypervisor_hostname'
                 'flavor', 'tenant_id', 'user_id', 'addresses']

###
Simple wrapper around nova server API
###
class $cross.Server extends $cross.APIResourceWrapper
  constructor: (instance, attrs) ->
    super instance, attrs

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
  projects = $http.get(serverUrl + 'projects')
    .then (response) ->
      return response.data
  # TODO(ZhengYue): The user list interface not implement

  getAddr = (addresses) ->
    fixed = []
    floating = []
    if addresses.private
      for addr in addresses.private
        if addr['OS-EXT-IPS:type'] == 'fixed'
          fixed.push addr.addr
        else if addr['OS-EXT-IPS:type'] == 'floating'
          floating.push addr.addr

    return {fixed: fixed, floating: floating}

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
        projectId = serverObj.tenant_id
        if projectsMap[projectId]
          serverObj.project = projectsMap[serverObj.tenant_id]['name']
        else
          serverObj.project = null
        delete serverObj.flavor

        address = JSON.parse(serverObj.addresses)
        addresses = getAddr address
        serverObj.fixed = addresses.fixed
        serverObj.floating = addresses.floating
        delete serverObj.addresses

        serverList.push serverObj

      callback serverList, values[0].total

###
Get a server.
###
$cross.serverGet = ($http, $window, $q, instanceId, callback) ->
  if !instanceId
    return
  serverUrl = $window.crossConfig.backendServer
  flavors = $http.get(serverUrl + 'os-flavors')
    .then (response) ->
      return response.data
  projects = $http.get(serverUrl + 'projects')
    .then (response) ->
      return response.data
  server = $http.get(serverUrl + 'servers/' + instanceId)
    .then (response) ->
      return response.data

  getAddr = (addresses) ->
    fixed = []
    floating = []
    if addresses.private
      for addr in addresses.private
        if addr['OS-EXT-IPS:type'] == 'fixed'
          fixed.push addr.addr
        else if addr['OS-EXT-IPS:type'] == 'floating'
          floating.push addr.addr

    return {fixed: fixed, floating: floating}

  $q.all([flavors, projects, server])
    .then (values) ->
      flavorMap = {}
      projectsMap = {}
      # NOTE(ZhengYue): Package flavor/project/user info into
      # a Object which indexed with id.
      for flavor in values[0].data
        flavorObj = new $cross.Flavor(flavor, ['name', 'id', 'vcpus', 'ram', 'disk'])
        flavorMap[flavor.id] = flavorObj.getObject(flavorObj)

      for project in values[1].data
        projectObj = new $cross.Project(project, ['name'])
        projectsMap[project.id] = projectObj.getObject(projectObj)

      server = new $cross.Server(values[2], instanceAttrs)
      serverObj = server.getObject(server)
      flavorId = JSON.parse(serverObj.flavor).id
      serverFlavor = flavorMap[flavorId]
      serverObj.disk = serverFlavor['disk']
      serverObj.vcpus = serverFlavor['vcpus']
      serverObj.ram = serverFlavor['ram']
      serverObj.project = projectsMap[serverObj.tenant_id]['name']
      delete serverObj.flavor

      address = JSON.parse(serverObj.addresses)
      addresses = getAddr address
      serverObj.fixed = addresses.fixed
      serverObj.floating = addresses.floating
      delete serverObj.addresses
      callback serverObj

###
Get a server.
###
$cross.serverDelete = ($http, $window, instanceId, callback) ->
  requestData =
    url: $window.crossConfig.backendServer + 'servers/' + instanceId
    method: 'DELETE'

  $http requestData
    .success (data, status, headers) ->
      callback status

$cross.serverLog = ($http, $window, instanceId, logLength=35, callback) ->
  if !instanceId
    return
  serverUrl = $window.crossConfig.backendServer
  requestData =
    url: serverUrl + 'servers/' + instanceId + '/action'
    method: 'POST'
    data: {"os-getConsoleOutput": {"length": logLength}}

  $http requestData
    .success (data, status, headers) ->
      if data
        callback data.data

$cross.serverConsole = ($http, $window, instanceId, callback) ->
  if !instanceId
    return
  serverUrl = $window.crossConfig.backendServer
  requestData =
    url: serverUrl + 'servers/' + instanceId + '/action'
    method: 'POST'
    data: {"os-getVNCConsole": {"type": "novnc"}}

  $http requestData
    .success (data, status, headers) ->
      if data
        callback data

action_dispatcher = (action) ->
  # TODO(ZhengYue): Full the action, current is sample set
  actionDataMap = {
    'reboot': {'reboot': {"type": "HARD"}},
    'os-getVNCConsole':{'os-getVNCConsole': {"type": "novnc"}},
    'poweroff': {'os-stop': null},
    'poweron': {'os-start': null},
    'suspend': {'suspend': null},
    'wakeup': {'resume': null},
  }
  return actionDataMap[action]

$cross.instanceAction = (action, $http, $window, instanceId, callback) ->
  if !instanceId
    return
  serverUrl = $window.crossConfig.backendServer
  requestData =
    url: serverUrl + 'servers/' + instanceId + '/action'
    method: 'POST'
    data: action_dispatcher(action)

  $http requestData
    .success (data, status, headers) ->
      if data
        callback data
