'use strict'

###*
 # @ngdoc function
 # @name Cross.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the Cross
###
angular.module("Cross.admin.overview")
  .controller "admin.overview.OverviewCtr", ($scope, $http, $q, $window) ->
    # Initial note.
    $scope.note =
      resource: {
        lead: $window._ "System Resource"
        vm: $window._ "VMs"
        host: $window._ "PMs"
        cluster: $window._ "Clusters"
        volume: $window._ "Volumes"
        unit: $window._ "num"
      }
      usage: {
        lead: $window._ "Resource usage"
        vcpu: $window._ "vCPUs usage"
        ram: $window._ "Memory usage"
        volume: $window._ "Volume usage"
        floatingIP: $window._ "Public IP usage"
      }
      topology: {
        lead: $window._ "Hosts topology"
      }
      message: {
        lead: $window._ "Latest message"
        more: $window._ "more"
      }

    baseURL = $window.$CROSS.settings.serverURL
    httpClusters = $http.get "#{baseURL}/os-clusters"
    httpStatistic = $http.get "#{baseURL}/os-hypervisors/statistics"
    httpFloatingIp = $http.get "#{baseURL}/os-floating-ips-bulk"
    httpHyper = $http.get "#{baseURL}/os-hypervisors/detail"
    httpInstances = $http.get "#{baseURL}/servers?limit_from=0&limit_to=0"
    $q.all([
      httpClusters, httpStatistic,
      httpFloatingIp, httpHyper
      httpInstances
    ]).then (values)->
        clusters = values[0].data
        statistic = values[1].data
        ips = values[2].data
        stats = utils.getUsage clusters, statistic, ips

        # handle vcpu usage.
        stats.vcpu = 0
        if stats.vcpuTotal
          stats.vcpu = 100 * stats.vcpuUsed / stats.vcpuTotal
          stats.vcpu = Math.round stats.vcpu
        stats.vcpuState = 'ok'
        if stats.vcpu > utils._WARN_THREATHOLD_
          stats.vcpuState = 'warn'
        stats.vcpuTotal = "#{stats.vcpuTotal}vcpus"

        # handle memory usage.
        stats.ram = 0
        if stats.ramTotal
          stats.ram = 100 * stats.ramUsed / stats.ramTotal
          stats.ram = Math.round stats.ram
        stats.ramState = 'ok'
        if stats.ram > utils._WARN_THREATHOLD_
          stats.ramState = 'warn'
        stats.ramTotal = utils.getRamFix stats.ramTotal
        stats.ramUsed = utils.getRamFix stats.ramUsed

        # handle volume usage.
        stats.volume = 0
        if stats.volumeTotal
          stats.volume = 100 * stats.volumeUsed
          stats.volume /= stats.volumeTotal
          stats.volume = Math.round stats.volume
        stats.volumeState = 'ok'
        if stats.volume > utils._WARN_THREATHOLD_
          stats.volumeState = 'warn'
        stats.volumeTotal = utils.getRamFix stats.volumeTotal
        stats.volumeUsed = utils.getRamFix stats.volumeUsed

        # handle floating ip usage.
        stats.floatingIP = 0
        if stats.floatingIPTotal
          stats.floatingIP = 100 * stats.floatingIPUsed
          stats.floatingIP /= stats.floatingIPTotal
          stats.floatingIP = Math.round stats.floatingIP
        stats.floatingIPState = 'ok'
        if stats.floatingIP > utils._WARN_THREATHOLD_
          stats.floatingIPState = 'warn'
        $scope.usage = stats

        # load resource statistic.
        hypers = values[3].data
        vms = values[4].data
        resource = utils.getResource clusters, hypers, vms
        resource.volumes = 10
        $scope.resource = resource
        hostView = utils.initialTopology clusters, hypers, vms
        $scope.topology =
          hostView: hostView
      , (err) ->
        console.log "Get resource with error: ", err

    $http.get("#{baseURL}/messages", {
      params:
        "current_page": 0
        "page_size": 10
        "source": "['feedback', 'workflow']"
    }).success (messages) ->
      if not messages
        # TODO:(lixipeng) messages empty handle.
        return
      msgRec = []
      for message in messages.list
        msgRec.push({
          creat_at: utils.prettyTime message.created_at
          content: message.event_type
        })
      $scope.messages = msgRec

    return

utils =
  _HYPERVISOR_TYPE_:
    qemu: "QEMU"
    vmware: "VMWare Vcenter"
  # Warn threathold.
  _WARN_THREATHOLD_: 90
  _RAND_KEEPER_: 1

  prettyTime: (time) ->
    if not time
        return ""

    cur_date = new Date()
    if time.indexOf('T') != -1
        time = time.split 'T'
    else
      time = time.split ' '

    yy = time[0].split '-'
    mm = time[1].split ':'

    pYear = parseFloat(yy[0])
    pMonth = parseFloat(yy[1]) - 1
    pDay = parseFloat(yy[2])
    pHour = parseFloat(mm[0])
    pMinute = parseFloat(mm[1])
    pSec = parseFloat(mm[2])
    date = Date.UTC pYear, pMonth, pDay, pHour, pMinute, pSec, 0

    cYear = cur_date.getUTCFullYear()
    cMonth = cur_date.getUTCMonth()
    cDay = cur_date.getUTCDate()
    cHour = cur_date.getUTCHours()
    cMinute = cur_date.getUTCMinutes() + 1
    cSec = cur_date.getUTCSeconds()

    cu_date = Date.UTC cYear, cMonth, cDay, cHour, cMinute, cSec, 0
    diff = ((cu_date - date) / 1000);
    day_diff = ~~(diff / 86400);
    if isNaN(day_diff)
      return;
    else if diff < 0
      day_diff = -day_diff
      diff = -diff
      if day_diff >= 366
        return Math.ceil(day_diff / 365) + ' years latter'
      else if day_diff == 0 && diff < 60
        return "#{diff} s latter"
      else if day_diff == 0 && diff < 120
        return '1 min latter'
      else if day_diff == 0 && diff < 3600
        return "#{Math.floor(diff/60)} min latter"
      else if day_diff && diff < 7200
        return '1 hour latter'
      else if day_diff == 0 && diff < 86400
        return "#{Math.floor(diff/3600)} h latter"
      else if day_diff == 0 && day_diff == 1
        return "tomorrow"
      else if day_diff < 7
        return "#{day_diff} d latter"
      else if day_diff < 31
        return "#{Math.ceil(day_diff/7)} w latter"
      else
        return "#{Math.ceil(day_diff/30)} m latter"

    if day_diff >= 365
      return "#{Math.ceil(day_diff/365)} y ago"
    else if day_diff == 0 && diff < 60
      return "#{diff} s' ago"
    else if day_diff == 0 && diff < 120
      return '1 min ago'
    else if day_diff == 0 && diff < 3600
      return "#{Math.floor(diff/60)} min ago"
    else if day_diff == 0 && diff < 7200
      return "1 h ago"
    else if day_diff == 0 && diff < 86400
      return "#{Math.floor(diff/3600)} h ago"
    else if day_diff == 0 && day_diff == 1
      return "Yesterday"
    else if day_diff < 7
      return "#{day_diff} d ago"
    else if day_diff < 31
      return "#{Math.ceil(day_diff/7)} w ago"
    else if day_diff < 365
      return "#{Math.ceil(day_diff/30)} m ago"


  _initialHyperDict: (hypers) ->
    hyperDict = {}
    for hyper in hypers
      key = "host_#{hyper.id}"
      hyperDict[key] =
        name: hyper.hypervisor_hostname
        vms: hyper.running_vms
    return hyperDict

  # initial topology
  initialTopology: (clusters, hypers, vms) ->
    hostView =
      root:
        type: "root"
        children: []
        id: "root"
        parent: null
    hyperType = utils._HYPERVISOR_TYPE_

    hyperDict = utils._initialHyperDict hypers
    for cluster in clusters
      hostView.root.children.push("cluster_#{cluster.id}")
      cluster_id = "cluster_#{cluster.id}"
      hostView[cluster_id] =
        type: "cluster"
        children: []
        id: cluster_id
        parent: "root"
        name: cluster.name
      for node in cluster.compute_nodes
        host_id = "host_qemu_#{node.id}"
        delete hyperDict[host_id]
        if node.hypervisor_type == hyperType.qemu
          hostView[cluster_id].children.push(host_id)
          hostView[host_id] =
            type: "host"
            children: []
            id: host_id
            parent: cluster_id
            name: node.hypervisor_hostname
            not_show_children: true
            running_vms: node.running_vms
          continue
        for h in node.physical_servers
          host_id = "host_vmware_#{h.id}"
          hostView[cluster_id].children.push(host_id)
          hostView[host_id] =
            type: "host"
            children: []
            id: host_id
            parent: cluster_id
            name: h.name
            not_show_children: true
            running_vms: h.running_vms
    noneClusterHosts = []
    for hyper of hyperDict
      if hyperDict[hypers]
        host_id = "host_qemu_#{hyper}"
        hostView[host_id] =
          type: "host"
          children: []
          id: host_id
          parent: "cluster_0"
          name: hyperDict[hyper].name
          not_show_children: true
          running_vms: hyperDict[hyper].vms
        noneClusterHosts.push("host_qemu_#{hyper}")
    if noneClusterHosts.length
      hostView["cluster_0"] =
        type: "cluster"
        children: noneClusterHosts
        id: "cluster_0"
        parent: "root"
        name: "default"
      hostView.root.children.push("cluster_0")
    return hostView

  getResource: (clusters, hypervisors, instances) ->
    stats =
      clusters: clusters.length
      hosts: hypervisors.length
      vms: instances.total

    hyperType = utils._HYPERVISOR_TYPE_
    for cluster in clusters
      if cluster.hypervisor_type == hyperType.qemu
        continue
      for node in cluster.compute_nodes
        stats.hosts += node.physical_servers.length - 1
    return stats

  rand: (num, keep=utils._RAND_KEEPER_) ->
    if angular.isNumber(num)
      keep = Number keep
      if isNaN(keep) or keep < 0
        keep = utils._RAND_KEEPER_
      keeper = Math.pow(10, keep)
      num = Math.round(num * keeper) / keeper
    return num

  ###*
  # Get resource usage.
  #
  ###
  getUsage: (clusters, statistic, ips) ->
    # build resource usage.
    stats = utils._caculateUsage clusters
    stats.vcpuTotal += statistic.vcpus
    stats.vcpuUsed += statistic.vcpus_used
    stats.ramTotal += statistic.memory_mb
    stats.ramUsed += statistic.memory_mb_used
    stats.volumeTotal += statistic.local_gb
    stats.volumeUsed += statistic.local_gb_used
    ipUsage = utils._caculateFloatingIpUsage ips
    stats.floatingIPTotal = ipUsage.total
    stats.floatingIPUsed = ipUsage.used
    return stats

  getRamFix: (num) ->
    if num < 1024
      return "#{num}MB"
    if num < 1024 * 1024
      return "#{utils.rand(num/1024)}GB"
    if num < 1024 * 1024 * 1024
      return "#{utils.rand(num/1024/1024)}TB"
    return "#{utils.rand(num/1024/1024/1024)}PB"

  getDiskFix: (num) ->
    if num < 1024
      return "#{num}GB"
    if num < 1024 * 1024
      return "#{utils.rand(num/1024)}TB"
    return "#{utils.rand(num/1024/1024)}PB"

  _caculateFloatingIpUsage: (ips) ->
    ipUsage =
      used: 0
      total: ips.length
    for ip in ips
      if ip.project_id
        ipUsage.used += 1
    return ipUsage

  _caculateUsage: (clusters) ->
    statistic =
      vcpuTotal: 0
      vcpuUsed: 0
      volumeUsed: 0
      volumeTotal: 0
      ramUsed: 0
      ramTotal: 0
    sharedStorage = []
    hyperType = utils._HYPERVISOR_TYPE_
    for cluster in clusters
      if cluster.hypervisor_type == hyperType.qemu
        continue
      for node in cluster.compute_nodes
        statistic.vcpuTotal += node.vcpus
        statistic.vcpuUsed += node.vcpus_used
        statistic.ramTotal += node.memory_mb
        statistic.ramUsed += node.memory_mb_used
        if cluster.shared_storage in sharedStorage
          statistic.volumeTotal += node.local_gb
          statistic.valumeUsed += node.local_gb_used
      if cluster.shared_storage != "N/A"
        sharedStorage.push(cluster.shared_storage)
    return statistic
