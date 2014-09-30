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
  dashboard = panelView.dashboard || "admin"
  panelGroup = panelView.panelGroup
  panel = panelView.panel
  permissions = panelView.permissions
  moduleName = "Cross.#{dashboard}.#{panel.slug}"
  app = angular.module(moduleName, [
      "ngAnimate",
      "ngResource",
      "ngRoute",
      "ui.router",
      "Cross.provider"
  ])

  app.config ($stateProvider, $httpProvider, $modalStateProvider) ->
    _BASE_URL = "scripts/dashboards/#{dashboard}/#{panel.slug}/"
    _SLUG_ = "/#{dashboard}"
    $httpProvider.defaults.useXDomain = true
    $httpProvider.defaults.withCredentials = true
    delete $httpProvider.defaults.headers.common['X-Requested-With']
    for route in routes

      _BASE_ = "#{dashboard}.#{panel.slug}"
      url = route.url.replace(/\//g, ".")
      $stateProvider
        .state "#{dashboard}#{url}",
          url: "#{_SLUG_}#{route.url}"
          templateUrl: "#{_BASE_URL}#{route.templateUrl}"
          controller: "#{_BASE_}.#{route.controller}"
      if not route.subStates
        continue

      subs = route.subStates
      for sub in subs
        subUrl = sub.url.replace(/\//g, ".")
        subUrl = subUrl.replace(":", "")
        if sub.modal
          hCls = "class='cross-modal-header'"
          headerTem = "'views/common/_modal_header.html'"
          header = "<div #{hCls} ng-include src=\"#{headerTem}\"></div>"
          cCls = "class='cross-modal-center'"
          centerTem = "'views/common/_modal_fields.html'"
          if sub.templateUrl
            centerTem = "'#{_BASE_URL}#{sub.templateUrl}'"
          larger = false
          if not sub.descTemplateUrl
            center = "<div #{cCls} ng-include src=\"#{centerTem}\"></div>"
          else
            descTem = "'#{_BASE_URL}#{sub.descTemplateUrl}'"
            desCls = "class='cross-modal-des'"
            center = "<div #{cCls} ng-include src=\"#{centerTem}\"></div>" +\
                     "<div #{desCls} ng-include src=\"#{descTem}\"></div>"
            larger = true
          $modalStateProvider
            .state "#{dashboard}#{url}#{subUrl}",
              url: "#{sub.url}"
              template: "#{header}#{center}"
              controller: "#{_BASE_}.#{sub.controller}"
              larger: larger
          continue
        $stateProvider
          .state "#{dashboard}#{url}#{subUrl}",
            url: "#{sub.url}"
            templateUrl: "#{_BASE_URL}#{sub.templateUrl}"
            controller: "#{_BASE_}.#{sub.controller}"
        if not sub.subStates
          continue
        for nest in sub.subStates
          nestUrl = nest.url.replace(/\//g, ".")

          if nest.modal
            hCls = "class='cross-modal-header'"
            headerTem = "'views/common/_modal_header.html'"
            header = "<div #{hCls} ng-include src=\"#{headerTem}\"></div>"
            cCls = "class='cross-modal-center'"
            centerTem = "'views/common/_modal_fields.html'"
            if nest.templateUrl
              centerTem = "'#{_BASE_URL}#{nest.templateUrl}'"
            larger = false
            if not nest.descTemplateUrl
              center = "<div #{cCls} ng-include src=\"#{centerTem}\"></div>"
            else
              descTem = "'#{_BASE_URL}#{nest.descTemplateUrl}'"
              desCls = "class='cross-modal-des'"
              center = "<div #{cCls} ng-include src=\"#{centerTem}\"></div>" +\
                       "<div #{desCls} ng-include src=\"#{descTem}\"></div>"
              larger = true
            $modalStateProvider
              .state "#{dashboard}#{url}#{subUrl}#{nestUrl}",
                url: "#{nest.url}"
                template: "#{header}#{center}"
                controller: "#{_BASE_}.#{nest.controller}"
                larger: larger
            continue

          $stateProvider
            .state "#{dashboard}#{url}#{subUrl}#{nestUrl}",
              url: "#{nest.url}"
              templateUrl: "#{_BASE_URL}#{nest.templateUrl}"
              controller: "#{_BASE_}.#{nest.controller||sub.controller}"
              substate: true
              resolve:
                data: ($http, $window, $q) ->
                  $cross.listDetailedServers $http, $window, $q, {},
                  (instances, total) ->
                    return instances

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
