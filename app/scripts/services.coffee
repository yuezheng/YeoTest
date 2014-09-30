'use strict'

###
 # @description
 # # The services module of Cross
 #
 # loginCheck service is used for user is login or not
###

angular.module('loginCheck', [])
  .factory '$logincheck' , ($http, $state) ->
    return ($http, $state, next, toParams, event) ->
      params =
        url: window.$CROSS.settings.serverURL
        method: 'GET'
      $http params
        .success (data, status, headers) ->
          event.preventDefault()
          if !angular.equals(toParams, {}) and next.substate
            angular.forEach toParams, (index, key) ->
              if toParams[key] != undefined and toParams[key] != ""
                $state.go next, toParams
          $cross.initialCentBox()
        .error (error, status) ->
          event.preventDefault()
          $state.go 'login'
  .service 'svgService', () ->
    xmlns = "http://www.w3.org/2000/svg"

    compileNode = (angularElement) ->
      rawElement = angularElement[0]
      if !rawElement.localName
        text = document.createTextNode rawElement.wholeText
        return angular.element text

      replacement = document.createElementNS(xmlns, rawElement.localName)
      chiledren = angularElement.children()

      angular.forEach children, (value) ->
        newChildNode = compileNode(angular.element(value))
        replacement.appendChild newChildNode[0]

      attributes = rawElement.attributes
      for attr in attributes
        replacement.setAttribute(attr.name, attr.value)

      if rawElement.localName == 'text'
        replacement.textContent = rawElement.innertext

      angularElement.replaceWidth replacement
      return angular.element replacement

  this.compile = (ele, attrs, transclude) ->
    compileNode ele

    postLink = (scope, ele, attrs, controller) ->
      console.log 'fefe'

    return postLink
