__CROSS_SETTINGS__ =
  dashboards: ["menu", "admin", "project"]
  serverURL: "http://localhost:4000"
  locale: "ZH_CN"
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
    return
