'use strict'

# routes for overview panel
routes =[
  {
    url: '/instance'
    templateUrl: 'views/index.html'
    controller: 'InstanceCtr'
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
