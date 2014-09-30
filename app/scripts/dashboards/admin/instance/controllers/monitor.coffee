'use strict'

angular.module('Cross.admin.instance')
  .controller 'admin.instance.InstanceMonCtr', ($scope, $http,
                                            $window, $q, $stateParams, $state) ->
    currentInstance = $stateParams.instanceId
    # TODO(ZhengYue): Add feature for query log by length
    $scope.cpuUtil = {
      title: 'CPU Util'
      unit: '%'
      dataSet: [
        {
          title: 'test'
          data: [
            {
              x: '11'
              y: '22'
            }
            {
              x: '21'
              y: '32'
            }
            {
              x: '305'
              y: '99'
            }
            {
              x: '196'
              y: '433'
            }
            {
              x: '6996'
              y: '433'
            }
          ]
          conifg: {
            title: 'dd'
            lineColor: 'red'
            pointColor: 'black'
          }
        }
      ]
    }
