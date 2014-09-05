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
