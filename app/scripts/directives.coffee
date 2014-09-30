'use strict';

###*
 #
 #Directives
 #
###
angular.module("Cross.directives", [])
  .directive "sectorDirective", ->
    {
      restrict: "C"
      scope:
        val: "="
      link: ($scope, $ele) ->
        $scope.$watch 'val', (val) ->
          # If val data not ready, skip.
          if val == undefined
            return

          if $cross.animateSector and $ele.find("path").length > 0
            $inner = $ele.find(".sector-inner").eq(0)
            $outer = $ele.find(".sector-outer").eq(0)
            percent = val
            innerSize = $inner.width()
            outerSize = $outer.width()
            path = $ele.find("path")[0]
            $cross.animateSector path,
              centerX: outerSize / 2
              centerY: outerSize / 2
              startDegrees: 0
              endDegrees: parseInt(3.60 * percent)
              innerRadius: innerSize / 2
              outerRadius: outerSize / 2
              animate: true
    }
  .directive "hostTopologyDirective", ->
    {
      restrict: "C"
      scope:
        val: "="
      link: ($scope, $ele) ->
        $scope.$watch "val", (hostView) ->
          # If topology or hostView data not ready, skip.
          if not hostView
            return

          #options =
          #  type: "star"
          options = {}
          $cross.topology.drawHostView hostView, $ele, options
    }
  .directive "selectDirective", ->
    {
      restrict: "C"
      scope:
        val: "="
      link: ($scope, $ele) ->
        name = $ele.attr "name"
        select = $ele.siblings "[target='#{name}']"
        if not select.length
          select = angular.element("<div></div>")
          select.addClass "wrap-select-field"
          select.addClass "wrap-selection"
          select.attr "target", name

          # initial selected field.
          selectedArea = angular.element "<div></div>"
          selectedArea.addClass "wrap-select-selected"
          selectedArea.addClass "wrap-selection"
          inputArea = angular.element "<input />"
          inputArea.attr "type", "text"
          inputArea.addClass "wrap-select-input"
          inputArea.addClass "wrap-selection"
          $selectedOpt = $ele.find("option[selected]")
          if $selectedOpt.length
            inputArea.attr "value", $selectedOpt.eq(0).html()
          inputArea.appendTo selectedArea
          clkAct = angular.element "<div></div>"
          clkAct.addClass "wrap-select-clk"
          clkAct.addClass "wrap-selection"
          clkAct.appendTo selectedArea
          selectedArea.appendTo select

          # bind action.
          inputArea.bind "click", ->
            $this = angular.element @
            $select = $this.parent()
            $select.trigger "click"

          clickAct = (event) ->
            $this = angular.element @
            $this.addClass "focus"
            $select = $this.parent()
              .find(".wrap-select-list").eq(0)
            $select.slideDown()

          blurAct = (event) ->
            $target = angular.element event.target
            if not $target.hasClass "wrap-selection"
              select.find(".wrap-select-selected")
                .removeClass "focus"
              select.find(".wrap-select-list").slideUp()

          selectedArea.bind "click", clickAct
          $(".modal").bind "click", blurAct
          inputArea[0].oninput = (event) ->
            val = angular.element(@).val()
            opts = select.find(".wrap-select-option")
            grps = select.find(".wrap-select-optgroup")
            if not val
              grps.show()
              opts.removeAttr("hide").show()
            else
              val = val.toLowerCase()
              opts.each (ind) ->
                $opt = angular.element @
                lowerVal = String($opt.html()).toLowerCase()
                if lowerVal.indexOf(val) == -1
                  $opt.attr("hide", true).hide()
                else
                  $opt.removeAttr("hide").show()

        # initial options.
        initialOpts = ($list, $select) ->
          groups = $select.find("> optgroup")
          groups.each (index) ->
            $this = angular.element @
            grp = angular.element "<div></div>"
            grp.addClass "wrap-select-optgroup"
            grp.addClass "wrap-selection"
            grpLead = angular.element "<div></div>"
            grpLead.addClass "wrap-select-group-lead"
            grpLead.addClass "wrap-selection"
            grpLead.html $this.attr("label")
            grpLead.appendTo grp
            opts = $this.find "> option"
            opts.each (ind) ->
              $opt = angular.element @
              opt = angular.element "<div></div>"
              opt.addClass "wrap-select-option"
              opt.addClass "wrap-selection"
              opt.html $opt.html()
              opt.attr "value", $opt.val()
              opt.appendTo grp
            grp.appendTo $list
          defOpts = $select.find("> option")
          defOpts.each (index) ->
            $opt = angular.element @
            opt = angular.element "<div></div>"
            opt.addClass "wrap-select-option"
            opt.addClass "wrap-selection"
            opt.html $opt.html()
            opt.attr "value", $opt.val()
            opt.appendTo $list
          $opts = $list.find(".wrap-select-option")
          $opts.unbind "click"
          $opts.bind "click", ->
            $this = angular.element @
            $list.parent().find(".wrap-select-input")
              .attr "value", $this.html()
            $list.slideUp()
            $list.siblings(".wrap-select-selected")
              .removeClass("focus")
            val = $this.attr("value")
            $select.find("option").each ->
              $opt = angular.element @
              if $opt.val() == val
                fieldVals = $scope.val
                ngModel = $select.controller("ngModel")
                ngModel.$setViewValue fieldVals[val].value
                return false

        listArea = angular.element "<div></div>"
        listArea.addClass "wrap-select-list"
        initialOpts listArea, $ele
        listArea.appendTo select
        $ele.hide()
        select.insertAfter $ele

        $scope.$watch "val", (options) ->
          $list = select.find(".wrap-select-list")
          $input = select.find(".wrap-select-input")
          initialOpts $list, $ele
          $selectedOpt = $ele.find("option[selected]")
          if $selectedOpt.length
            inputArea.attr "value", $selectedOpt.eq(0).html()
    }
  .directive "selectAllCheckbox", ->
    return {
      replace: true,
      restrict: 'E',
      scope: {
        checkboxes: '='
        allselected: '=allSelected'
        allclear: '=allClear'
      },
      template: '<input type="checkbox" ng-model="master" ng-change="masterChange(); selectChange()">',
      controller: ($scope, $element) ->
        $scope.masterChange = () ->
          if $scope.master
            angular.forEach $scope.checkboxes, (cb, index) ->
              cb.isSelected = true
          else
            angular.forEach $scope.checkboxes, (cb, index) ->
              cb.isSelected = false

        $scope.$watch('checkboxes', () ->
          allSet = true
          allClear = true
          angular.forEach $scope.checkboxes, (cb, index) ->
            if cb.isSelected
              allClear = false
            else
              allSet = false

          if $scope.allselected != undefined
            $scope.allselected = allSet
          if $scope.allclear != undefined
            $scope.allclear = allClear

          $element.prop 'indeterminate', false
          if allSet
            $scope.master = true
          else if allClear
            $scope.master = false
          else
            $scope.master = false
            $element.prop 'indeterminate', true
        , true)
    }
  .directive 'dynamic', ($compile) ->
    return {
      restrict: 'A',
      replace: true,
      scope: true,
      link: (scope, ele, attrs) ->
        scope.$watch attrs.dynamic, (html) ->
          ele.html(html)
          $compile(ele.contents())(scope)
    }
  .directive "customSort", () ->
    return {
      restrict: 'A',
      transclude: true,
      scope: {
        order: '=',
        sort: '='
      },
      template:
        ' <a ng-click="sort_by(order)" style="color: #55555;"><span ng-transclude></span><i ng-class="selectedCls(order)"></i> </a>'
      link: (scope) ->
        scope.sort_by = (newSortingOrder) ->
          sort = scope.sort
          if sort.sortingOrder == newSortingOrder
            sort.reverse = !sort.reverse

          sort.sortingOrder = newSortingOrder

        scope.selectedCls = (column) ->
          if column == scope.sort.sortingOrder
            if scope.sort.reverse
              return 'icon-chevron-down'
            else
              return 'icon-chevron-up'
          else
            return 'iocon-sort'
    }
  .directive "datatable", () ->
    return {
      restrict: 'A',
      transclude: true,
      scope: {
        'datatable': '='
      },
      templateUrl: '../views/common/cross_table.html',
      link: (scope, ele, attr) ->
        scope.showPageCode = true
        scope.maxCounts = 5
        scope.sort = {
          sortingOrder: 'name'
          reverse: false
        }

        judgePages = (opts) ->
          if opts.pageMax
            scope.maxCounts = opts.pageMax
          currentPage = opts.pagingOptions.currentPage
          scope.pageCounts = opts.pageCounts
          scope.showPages = $cross.getPageCountList currentPage,
                            scope.pageCounts, scope.maxCounts
          if currentPage == 1 and scope.showPages.length > 1
            scope.unFristPage = false
            scope.showPageCode = true
            scope.unLastPage = true
          else if currentPage == 1 and scope.showPages.length == 1
            scope.showPageCode = false
          else
            scope.unFristPage = true
            scope.showPageCode = true
            if currentPage == scope.pageCounts
              scope.unLastPage = false

        scope.gotoPage = (index) ->
          if typeof(index) is 'number'
            scope.pagingOptions.currentPage = \
              scope.showPages[index] + 1
          else if index == 'next'
            scope.pagingOptions.currentPage = \
              scope.pagingOptions.currentPage + 1
          else if index == 'pre'
            scope.pagingOptions.currentPage = \
              scope.pagingOptions.currentPage - 1
          else if index == 'frist'
            scope.pagingOptions.currentPage = 1
          else if index == 'last'
            scope.pagingOptions.currentPage = scope.pageCounts

          judgePages scope.datatableOpts

        scope.$watch 'datatable', (datatableOpts) ->
          scope.datatableOpts = datatableOpts
          scope.pagingOptions = datatableOpts.pagingOptions
          scope.source = datatableOpts.data
          if scope.source and scope.source.length == 0
            scope.showFooter = false
          else
            scope.showFooter = true
          scope.showFooter = datatableOpts.showFooter || true
          judgePages datatableOpts
        , true
    }
  .directive('crossConfirm', ['$modal', ($modal, $templateCache) ->
    ModalInstanceCtrl = ($scope, $modalInstance, getAction) ->
      $scope.message = _ "Are you sure ?"
      $scope.cancelBtn = _ "Cancel"
      $scope.action = getAction
      $scope.ok = () ->
        $modalInstance.close()

      $scope.cancel = () ->
        $modalInstance.dismiss('cancel')

    return {
      restrict: 'A',
      scope: {
        crossConfirm: '&'
        items: '='
      },
      link: (scope, element, attrs) ->
        modalCall = () ->
          modalInstance = $modal.open {
            templateUrl: '../views/common/_cross_confirm_footer.html'
            controller: ModalInstanceCtrl
            resolve: {
              getAction: () ->
                return attrs.crossConfirmAction || 'Confirm'
            }
          }

          modalInstance.result.then( () ->
            scope.crossConfirm({items: scope.items})
          )

        scope.$watch 'items', (items) ->
          enabledStatus = ['btn-enable', 'enabled']
          if items.length > 0 and attrs.actionEnable in enabledStatus
            element.unbind()
            element.bind 'click', modalCall
          else
            element.unbind 'click', modalCall
        , true
    }
  ])
  .directive('checklistModel', ['$parse', '$compile', ($parse, $compile) ->
    # contains
    contains = (arr, item) ->
      if angular.isArray(arr)
        for val in arr
          if angular.equals val, item
            return true
      return false

    # add
    add = (arr, item) ->
      if not angular.isArray(arr)
        arr = []
      if item in arr
          return arr
      arr.push item
      return arr

    # remove
    remove = (arr, item) ->
      if not angular.isArray(arr)
        return arr
      counter = 0
      len = arr.length
      loop
        break if counter >= len
        val = arr[counter]
        if angular.equals val, item
          arr.splice counter, 1
          break
        counter += 1
      return arr

    postLinkFn = (scope, elem, attrs) ->
      # compile with `ng-model` pointing to `checked`
      $compile(elem)(scope);

      # getter / setter for original model
      getter = $parse attrs.checklistModel
      setter = getter.assign

      # value added to list
      value = $parse(attrs.checklistValue) scope.$parent

      # watch UI checked change
      elem.bind "mousedown", ->
        current = getter scope.$parent
        if not scope.checked
          setter scope.$parent, add(current, value)
        else
          setter scope.$parent, remove(current, value)

      # watch original model change
      scope.$parent.$watch(attrs.checklistModel, (newArr, oldArr) ->
        scope.checked = contains(newArr, value)
      , true)

    {
      restrict: 'A'
      priority: 1000
      terminal: true
      scope: true
      compile: ($ele, $attrs) ->
        tagName = $ele[0].tagName
        if tagName != 'INPUT' || !$ele.attr('type', 'checkbox')
          throw 'checklist-model should be applied' +\
                ' to `input[type="checkbox"]`.'

        if !$attrs.checklistValue
          throw 'You should provide `checklist-value`.'

        # exclude recursion
        $ele.removeAttr 'checklist-model'

        # local scope var storing individual checkbox model
        $ele.attr 'ng-model', 'checked'

        return postLinkFn
    }
  ])
  .directive "formAutofillFix", ->
    return (scope, elem, attrs) ->
        elem.prop('method', 'POST');

        # Fix autofill issues where Angular doesn't
        # know about autofilled inputs.
        elem.unbind("submit").submit (e) ->
          e.preventDefault()
          elem.find('input, textarea, select')
            .trigger('input').trigger('change').trigger('keydown')
          scope.$apply attrs.ngSubmit
  .directive "linegraph", () ->
    return {
      restrict: 'A'
      transclude: true
      scope: {
        'linegraph': '='
      }
      templateUrl: '../views/common/cross_line_graph.html'
      link: (scope, ele, attr) ->
        svgns = "http://www.w3.org/2000/svg"

        dataSet = scope.linegraph.dataSet[0].data
        # SVG config
        counts = dataSet.length
        svgNode = ele.find('svg')
        canvasWidth = svgNode.width() - 80
        canvasHeight = svgNode.height() - 50
        footInterval = canvasWidth / counts

        createXAxis = (index, footScale, coordinateHeight) ->
          scaleStartX = 40 + footScale * index
          scaleY = coordinateHeight
          scaleEndX = scaleStartX + footScale
          verticalLine = document.createElementNS(svgns, 'path')
          horizonLine = document.createElementNS(svgns, 'path')

          verticalLine.setAttributeNS(null, 'd',
            "M#{scaleStartX} #{scaleY} L#{scaleEndX} #{scaleY}")
          horizonLine.setAttributeNS(null, 'd',
            "M#{scaleStartX + 0.5} #{scaleY + 5} L#{scaleStartX + 0.5} #{scaleY + 0.2}")
          verticalLine.setAttributeNS(null, 'class', 'line')
          horizonLine.setAttributeNS(null, 'class', 'line')
          return [verticalLine, horizonLine]

        createYAxis = (dataList, ind, coordinateHeight) ->
          dataMaxY = 100
          # Get max Y value from dataList
          angular.forEach dataList, (data, index) ->
            if dataList[index + 1]
              if data.y > dataList[index + 1].y
                dataMaxY = data.y
              else
                dataMaxY = dataList[index + 1].y
            else
              dataMaxY = data.y
          console.log dataMaxY, '+++++++++++'

        path = []
        xScales = []
        yScales = []
        points = []
        angular.forEach dataSet, (data, index) ->
          # Confirm X axis
          startX = 40 + footInterval * index
          xAxisSet = createXAxis index, footInterval, canvasHeight
          console.log createYAxis dataSet, index, canvasHeight
          xScales.push xAxisSet[0]
          xScales.push xAxisSet[1]
          # TODO(ZhengYue) Confirm Y axis
          pointValueX = startX + footInterval / 2
          console.log canvasHeight, ')))))))))))))'
          maxY = 100
          percent = canvasHeight / maxY
          pointValueY = canvasHeight - data.y * percent
          console.log pointValueY
          point = document.createElementNS(svgns, 'circle')
          point.setAttributeNS(null, 'cx', pointValueX)
          point.setAttributeNS(null, 'cy', pointValueY)
          point.setAttributeNS(null, 'data-conX', data.x)
          point.setAttributeNS(null, 'data-conY', data.y)
          point.setAttributeNS(null, 'r', 3)
          xScales.push point
          
        xAxisGroup = svgNode.find('.x-axis')
        angular.forEach xScales, (foot, index) ->
          xAxisGroup.append foot
    }
