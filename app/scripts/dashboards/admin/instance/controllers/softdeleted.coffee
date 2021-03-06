'use strict'

###*
 # @ngdoc function
 # @name Cross.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the Cross
###
angular.module('Cross.admin.instance')
  .controller 'softDeletedCtrl', ($scope, $http, $window, $q,
                              $state, $interval, $templateCache,
                              $compile, $animate, $modal) ->
    serverUrl = $window.$CROSS.settings.serverURL

    # Category for instance action
    $scope.listServers = false
    $scope.singleSelectedItem = {}

    # Variates for dataTable
    # --start--

    # For checkbox select
    $scope.AllSelectedItems = false
    $scope.NoSelectedItems = true

    # For tabler footer and pagination or filter
    $scope.showFooter = true
    $scope.unFristPage = false
    $scope.unLastPage = false

    $scope.totalServerItems = 0
    $scope.pagingOptions = {
      pageSizes: [15, 25, 50]
      pageSize: 15
      currentPage: 1
    }
    $scope.filterOptions =
      filterText: '',
      useExternalFilter: true

    $scope.softDeleted = [
    ]

    $scope.softDeletedOpts = {
      pagingOptions: $scope.pagingOptions
      showCheckbox: true
      columnDefs: $scope.columnDefs
      pageMax: 5
    }

    $scope.judgeStatus = (item) ->
      if item.status in $scope.labileStatus
        item.labileStatus = 'unknwon'
      else if item.status in $scope.shutdowStatus
        item.labileStatus = 'stoped'
      else if item.status in $scope.abnormalStatus
        item.labileStatus = 'abnormal'
      else
        item.labileStatus = 'active'

      if item.task_state and item.task_state != 'null'
        item.labileStatus = 'unknwon'
      else
        item.task_state = ''

    # Function for get paded instances and assign class for
    # element by status
    $scope.setPagingData = (pagedData, total) ->
      $scope.softDeleted = pagedData
      $scope.totalServerItems = total
      # Compute the total pages
      $scope.pageCounts = Math.ceil(total / $scope.pagingOptions.pageSize)
      $scope.softDeletedOpts.data = $scope.softDeleted
      $scope.softDeletedOpts.pageCounts = $scope.pageCounts

      for item in pagedData
        $scope.judgeStatus item

      if !$scope.$$phase
        $scope.$apply()

    # --End--

    # Functions for handle event from action

    $scope.selectedItems = []
    # TODO(ZhengYue): Add batch action enable/disable judge by status
    $scope.selectChange = () ->
      if $scope.selectedItems.length == 1
        $scope.NoSelectedItems = false
        $scope.batchActionEnableClass = 'btn-enable'
        $scope.vncLinkEnableClass = 'btn-enable'
        $scope.singleSelectedItem = $scope.selectedItems[0]
      else if $scope.selectedItems.length > 1
        $scope.NoSelectedItems = false
        $scope.batchActionEnableClass = 'btn-enable'
        $scope.vncLinkEnableClass = 'btn-disable'
        $scope.singleSelectedItem = {}
        $state.go 'admin./instance'
      else
        $scope.NoSelectedItems = true
        $scope.batchActionEnableClass = 'btn-disable'
        $scope.vncLinkEnableClass = 'btn-disable'
        $scope.singleSelectedItem = {}
        $state.go 'admin./instance'

    $scope.detailShow = (item) ->
      # Judge the height and width of detail area
      $scope.clickedInstance = item
      container = angular.element('.ui-view-container')
      $scope.detailHeight = $(window).height() - container.offset().top
      $scope.detailHeight -= 40
      # 80% width of parent ele
      $scope.detailWidth = container.width() *  0.78
      $scope.offsetLeft = container.width() * 0.22

    # Functions about interaction with server
    # --Start--

    # periodic get instance data which status is 'processing'
    $scope.getLabileData = (instanceId) ->
      freshData = $interval(() ->
        $cross.serverGet $http, $window, $q, instanceId, (instance) ->
          $scope.listServers = false
          if instance
            if instance.task_state == null
              $interval.cancel(freshData)
            if instance.status not in $scope.labileStatus
              $interval.cancel(freshData)

            angular.forEach $scope.softDeleted, (row, index) ->
              if row.id == instance.id
                $scope.judgeStatus instance
                $scope.softDeleted[index] = instance
                if instance.status == 'DELETED'
                  $scope.softDeleted.splice(index, 1)
          else
            $interval.cancel(freshData)
            angular.forEach $scope.softDeleted, (row, index) ->
              if row.id == instanceId
                $scope.softDeleted.splice(index, 1)
      , 5000)

    # Function for async list instances
    $scope.getPagedDataAsync = (pageSize, currentPage, callback) ->
      setTimeout(() ->
        $scope.listServers = true
        currentPage = currentPage - 1
        dataQueryOpts =
          dataFrom: parseInt(pageSize) * parseInt(currentPage)
          dataTo: parseInt(pageSize) * parseInt(currentPage) + parseInt(pageSize)
        $cross.listDetailedServers $http, $window, $q, dataQueryOpts,
        (instances, total) ->
          $scope.setPagingData(instances, total)
          (callback && typeof(callback) == "function") && callback()
      , 300)

    $scope.getPagedDataAsync($scope.pagingOptions.pageSize,
                             $scope.pagingOptions.currentPage,
                             () ->
                               $scope.listServers = false)

    # Callback for instance list after paging change
    watchCallback = (newVal, oldVal) ->
      tbody = angular.element('tbody.cross-data-table-body')
      tfoot = angular.element('tfoot.cross-data-table-foot')
      tbody.hide()
      tfoot.hide()
      loadCallback = () ->
        tbody.show()
        tfoot.show()
      if newVal != oldVal and newVal.currentPage != oldVal.currentPage
        $scope.getPagedDataAsync $scope.pagingOptions.pageSize,
                                 $scope.pagingOptions.currentPage,
                                 loadCallback

    $scope.$watch('pagingOptions', watchCallback, true)

    # Callback after instance list change
    instanceCallback = (newVal, oldVal) ->
      if newVal != oldVal
        selectedItems = []
        for instance in newVal
          if instance.status in $scope.labileStatus\
          or instance.task_state and instance.task_state != 'null'
            $scope.getLabileData(instance.id)
          if instance.isSelected == true
            selectedItems.push instance
        $scope.selectedItems = selectedItems

    $scope.$watch('softDeleted', instanceCallback, true)

    $scope.$watch('selectedItems', $scope.selectChange, true)

    # Delete selected servers
    $scope.deleteServer = () ->
      angular.forEach $scope.selectedItems, (item, index) ->
        instanceId = item.id
        $cross.serverDelete $http, $window, instanceId, (response) ->
          # TODO(ZhengYue): Add some tips for success or failed
          if response == 200
            # TODO(ZhengYue): Unify the tips for actions
            $scope.getLabileData(instanceId)
            toastr.success('Success delete server: ' + instanceId)

    $scope.serverAction = (action, group) ->
      actionName = $scope["#{group}Actions"][action].action
      angular.forEach $scope.selectedItems, (item, index) ->
        instanceId = item.id
        $cross.instanceAction actionName, $http, $window,
        instanceId, (response) ->
          # TODO(ZhengYue): Add some tips for success or failed
          # If success update instance predic
          if response
            $scope.getLabileData(instanceId)
            toastr.success('Success')

    # --End--

    # TODO(ZhengYue): Add loading status
    $scope.refresResource = (resource) ->
      tbody = angular.element('tbody.cross-data-table-body')
      tfoot = angular.element('tfoot.cross-data-table-foot')
      tbody.hide()
      tfoot.hide()
      loadCallback = () ->
        tbody.show()
        tfoot.show()
        toastr.options.closeButton = true
        toastr.success('Refresh Success')
      $scope.getPagedDataAsync($scope.pagingOptions.pageSize,
                               $scope.pagingOptions.currentPage,
                               loadCallback)

