__CROSS_SETTINGS__ =
  dashboards: ["menu", "admin", "project"]
  serverURL: "http://200.21.3.2:4000"
  locale: "zh_cn"
  defaultView: 'admin'


###
# Load global settings.
#
###
angular.module('Cross.settings', [])
  .run ($http, $window) ->
    #$http.get('/services')
    #  .success (services) ->
    #    console.log services
    $window.$CROSS = $window.$CROSS || {}
    $window.$CROSS.settings = __CROSS_SETTINGS__
    $window.$CROSS.permissions = []
    $cross.initialLocal __CROSS_SETTINGS__.locale
    return

