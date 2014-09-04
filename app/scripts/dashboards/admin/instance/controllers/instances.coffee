'use strict'

class APIResourceWrapper

  constructor: (apiresource, attrs) ->
    @_apiresource = apiresource
    @_attrs = attrs

  getObject: (obj) ->
    wappedObj = {}
    for attr in obj._attrs
      wappedObj.attr = obj._apiresource[attr]

    return wappedObj

class Server extends APIResourceWrapper

  constructor: (instance, attrs) ->
    super instance, attrs

instance = new Server({'name': 'haha'}, ['name'])
console.log instance.getObject(instance)
