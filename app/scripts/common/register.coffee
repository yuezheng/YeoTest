###*
 # Register panel for specific dashboard.
 #
 # Options of panelView:
 #   `dashboard`: dashboard of panel, such as 'admin'/'project'.
 #   `panelGroup`: panelGroup of this panel.
 #   `panel`: This panel properties.
 #   `permissions`: permissions about whether to show panel.
 #
 # Options of routes is a list, item as:
 #   `url`: url for route.
 #   `templateUrl`: url of template would be used for route.
 #   `controller`: controller would be used for route.
 #
 # @param: {object} Panel options.
 # @routes: {object} routes for this panel.
 #
###
$cross.registerPanel = (panelView, routes)->
  dashboard = panelView.dashboard
  panelGroup = panelView.panelGroup || "admin"
  panel = panelView.panel
  permissions = panelView.permissions
  moduleName = "Cross.#{dashboard}.#{panel.slug}"
  app = angular.module(moduleName, [
      "ngAnimate",
      "ngResource",
      "ngRoute",
      "ui.router",
  ])

  app.config ($stateProvider, $httpProvider) ->
    _BASE_URL = "scripts/dashboards/#{dashboard}/#{panel.slug}/"
    _SLUG_ = "/#{dashboard}"
    $httpProvider.defaults.useXDomain = true
    $httpProvider.defaults.withCredentials = true
    delete $httpProvider.defaults.headers.common['X-Requested-With']
    for route in routes
      $stateProvider
        .state "#{dashboard}.#{route.url}",
          url: "#{_SLUG_}#{route.url}"
          templateUrl: "#{_BASE_URL}#{route.templateUrl}"
          controller: route.controller
      if route.subState
        $stateProvider
          .state "#{dashboard}.#{route.url}.detail",
            url: "#{_SLUG_}#{route.url}#{route.subState.url}"
            templateUrl: "#{_BASE_URL}#{route.subState.templateUrl}"
            controller: route.subState.controller

    return

  app.run ($rootScope, $window, $state) ->
    cross = $window.$CROSS || {}
    $window.CROSS = cross
    permissions = cross.permissions || []
    isAddPanel = false
    #if not permissions
    #  isAddPanel = true
    #if typeof permissions == "Function"
    #  if permissions(permissions, $rootScope)
    #    isAddPanel = true
    #else
    #  if permissions in permissions
    #    isAddPanel = true
    isAddPanel = true
    if isAddPanel
      $window.$CROSS.panels = $window.$CROSS.panels || []
      key = "#{dashboard}.#{panelGroup.slug}.#{panel.slug}"
      $window.$CROSS.panels[key] = panel.name

    console.log $state.get()
    return

###*
 # Register dashboard.
 #
 # Options of panelView:
 #   `dashboard`: dashboard of panel, such as 'admin'/'project'.
 #   `panelGroup`: panelGroup of this panel.
 #   `panel`: This panel properties.
 #   `permissions`: permissions about whether to show panel.
 #
 # Options of routes is a list, item as:
 #   `url`: url for route.
 #   `templateUrl`: url of template would be used for route.
 #   `controller`: controller would be used for route.
 #
 # @param: {object} Panel options.
 # @routes: {object} routes for this panel.
 #
###
$cross.registerDashboard = (dashboardView, panels)->
  permissions = dashboardView.permissions
  moduleName = "Cross.#{dashboardView.slug}"
  panelModules = []
  for panelGroup in panels
    for panel in panelGroup.panels
      panelModules.push("Cross.#{dashboardView.slug}.#{panel}")
  app = angular.module(moduleName, panelModules)

  app.run ($rootScope, $window) ->
    cross = $window.$CROSS || {}
    $window.CROSS = cross
    permissions = cross.permissions || []
    isAddPanel = false
    #if not permissions
    #  isAddPanel = true
    #if typeof permissions == "Function"
    #  if permissions(permissions, $rootScope)
    #    isAddPanel = true
    #else
    #  if permissions in permissions
    #    isAddPanel = true
    isAddPanel = true
    if isAddPanel
      $window.$CROSS.dashboards = $window.$CROSS.dashboards || {}
      $window.$CROSS.dashboards[dashboardView.slug] = []
      allPanels = $window.$CROSS.panels || []
      for panelGroup in panels
        group = {
          name: panelGroup.name
          slug: panelGroup.slug
          panels: []
        }
        for panel in panelGroup.panels
          key = "#{dashboardView.slug}.#{panelGroup.slug}.#{panel}"
          group.panels.push({
            name: allPanels[key]
            slug: panel
          })
        $window.$CROSS.dashboards[dashboardView.slug].push(group)
    return
