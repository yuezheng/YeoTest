'use strict'

###
# filters
#
#
###
angular.module('Cross.filters', [])
  .filter 'i18n', ->
    return (text) ->
      if typeof text == "string"
        return _(text.toLocaleLowerCase())
      return text
  .filter 'unitSwitch', ->
    return (number) ->
      return number / 1024
