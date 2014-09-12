'use strict'

# routes for overview panel
routes =[
  {
    url: '/instance'
    templateUrl: 'views/index.html'
    controller: 'InstanceCtr'
    subState:
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
        }
        {
          url: '/monitor'
          templateUrl: 'views/_detail_monitor.html'
        }
      ]
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
