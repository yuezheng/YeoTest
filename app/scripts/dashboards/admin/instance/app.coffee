'use strict'

# routes for overview panel
routes =[
  {
    url: '/instance'
    templateUrl: 'views/index.html'
    controller: 'InstanceCtr'
    subStates: [{
      url: '/:instanceId'
      templateUrl: 'views/detail.html'
      controller: 'InstanceDetailCtr'
      subStates: [
        {
          url: '/overview'
          templateUrl: 'views/_detail_overview.html'
        }
        {
          url: '/log'
          templateUrl: 'views/_detail_log.html'
          controller: 'InstanceLogCtr'
        }
        {
          url: '/console'
          templateUrl: 'views/_detail_console.html'
          controller: 'InstanceConsoleCtr'
        }
        {
          url: '/monitor'
          templateUrl: 'views/_detail_monitor.html'
          controller: 'InstanceMonCtr'
        }
      ]
    }
    {
      url: '/:instId'
      controller: "InstanceActionCtrl"
      templateUrl: 'views/instanceAction.html'
      subStates: [
        {
          url: '/snapshot'
          modal: true
          controller: "SnapshotCreatCtrl"
        }
        {
          url: '/migrate'
          modal: true
          controller: "MigrateCtrl"
        }
      ]
    }]
  }
]

panel =
  dashboard: 'admin'
  panelGroup:
    slug: 'instance'
  panel:
    name: 'Instance'
    slug: 'instance'
  permissions: 'compute'

$cross.registerPanel(panel, routes)
