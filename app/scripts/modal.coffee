app = angular.module("Cross.provider", [
  "ui.router",
  "ui.bootstrap"
])

app.provider "$modalState", ($stateProvider) ->
    provider = @
    provider.$get = ->
      return provider

    provider.state = (stateName, options) ->
      modalInstance = undefined
      $stateProvider.state stateName, {
        modal: true
        url: options.url
        substate: options.substate || true
        onEnter: ["$modal", "$state", ($modal, $state) ->
          if options.larger
            options.windowClass = "window-larger"
          modalInstance = $modal.open(options)
          modalInstance.result.finally ->
            modalInstance = null
            if $state.$current.name == stateName
              $state.go('^')
        ]
        onExit: ->
          if modalInstance
            modalInstance.close()
      }
    return provider
