'use strict'

# routes for flavor panel
routes =[
  {
    url: '/flavor'
    templateUrl: 'views/index.html'
    controller: 'FlavorCtr'
    subStates: [{
      url: "/create"
      controller: "FlavorCreateCtr"
      modal: true
    }, {
      url: "/test"
      controller: "FlavorTestCtr"
      modal: true
      descTemplateUrl: "views/_testDes.html"
    }, {
      url: "/resize"
      controller: "FlavorResizeCtr"
      modal: true
      descTemplateUrl: "views/_resizeDes.html"
    }, {
      url: "/update"
      controller: "FlavorUpdateCtr"
      modal: true
    }]
  }
]

panel =
  dashboard: 'admin'
  panelGroup:
    slug: 'instance'
  panel:
    name: 'Flavor'
    slug: 'flavor'
  permissions: 'compute'

$cross.registerPanel(panel, routes)
