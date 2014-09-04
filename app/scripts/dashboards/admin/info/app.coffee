'use strict'

# routes for overview panel
routes =[
  {
    url: '/info'
    templateUrl: 'views/index.html'
    controller: 'InfoCtr'
  }
]

panel =
  dashboard: 'admin'
  panelGroup:
    slug: 'system'
  panel:
    name: 'Info'
    slug: 'info'
  permissions: 'compute'

$cross.registerPanel(panel, routes)
