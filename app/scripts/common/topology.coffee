# define topology module

$cross.topology =
  # node box size.
  _NODE_:
    width: 70
    height: 50
    root:
      width: 100
      height: 60
  # node distance between.
  _DISTANCE_:
    X: 30
    Y: 40
  # node type.
  _NODE_TYPE_:
    host: 'host'
    vm: 'vm'
    cluster: 'cluster'
    root: 'root'
  # max nodes for same generation.
  _MAX_SAME_GENERATION_NODES_: 15
  # nodes with those type show join.
  _JOIN_NODE_TYPE_: ['host', 'cluster']

  ###*
  # Add node tip
  #
  ###
  _addNodeTip: (options, target) ->
    if angular.element("##{options.id}").length
      tip = angular.element("##{options.id}")
    else
      tip = angular.element("<div></div>")
      tip.addClass "cross-topology-node-tip"
      tip.attr({
        id: options.id
        nodeId: options.nodeId
      }).appendTo target
    tip.css({
      left: options.left - 25
      top: options.top + 15
    }).html(options.number).fadeIn()

  ###*
  # Add line join
  #
  ###
  _addLineJoin: (options, target) ->
    if angular.element("##{options.id}").length
      join = angular.element("##{options.id}")
    else
      join = angular.element("<div></div>")
      join.addClass "cross-topology-line-join"
      join.attr({
        id: options.id
        nodeId: options.nodeId
      }).html("&ndash;").appendTo target
    join.css({
      left: options.left - join.width() / 2 + 1
      top: options.top
    });
    if options.expend then join.fadeOut() else join.fadeIn()

  ###*
  # Draw link.
  #
  ###
  _drawLink: (root, hostView, target, options) ->
    children = hostView[root].children
    if not children or not children.length
      return

    XMLNS = 'xmlns="http://www.w3.org/2000/svg"'
    VERSION = 'version="1.1"'
    STROKE_WIDTH = 2
    index = 0
    curr_x = 0
    pre_x = 0
    len = hostView[root].children.length

    # caculate width, height, initial line path.
    firstChildID = hostView[hostView[root].children[0]].id
    lastChildID = hostView[hostView[root].children[len - 1]].id
    $firstChildID = "#cross_topology_node_id_#{firstChildID}"
    $lastChildID = "#cross_topology_node_id_#{lastChildID}"
    firstChild = angular.element("#{$firstChildID}")
    lastChild = angular.element("#{$lastChildID}")
    width = parseInt(lastChild.attr("left"))
    width -= parseInt(firstChild.attr("left"))
    width += STROKE_WIDTH
    height = $cross.topology._DISTANCE_.Y
    d = "M#{width/2} 0 L#{width/2} #{height/2}"
    path = "<path d='#{d}' />"
    d = "M0 #{height/2} L#{width} #{height/2}"
    path += "<path d='#{d}' />"
    for child in children
      childID = "cross_topology_node_id_#{hostView[child].id}"
      curr_x = parseInt(angular.element("##{childID}").attr("left"))
      if index == 0
        pre_x = curr_x - STROKE_WIDTH / 2
      d = "M#{curr_x-pre_x} #{height/2} L#{curr_x-pre_x} #{height}"
      path += "<path d='#{d}' />"
      index += 1
    lineId = "cross_topology_line_id_#{hostView[root].id}"

    # Remove svg dom as it does not support jquery.html(path)
    if angular.element("##{lineId}").length
      angular.element("##{lineId}").remove()

    liner_str = "<svg class='cross-topology-line' #{XMLNS} #{VERSION}>"
    liner_str += path + '</svg>'
    liner = angular.element(liner_str)
    liner.attr({id: lineId}).appendTo target

    left = parseInt(firstChild.attr("left"))
    left += $cross.topology._NODE_.width / 2
    top = parseInt(firstChild.attr("top"))
    top -= $cross.topology._DISTANCE_.Y
    if root == $cross.topology._NODE_TYPE_.root
      top += $cross.topology._NODE_.root.height
      top -= $cross.topology._NODE_.height
    liner.attr({left: left, top: top})
      .css({
        width: width
        height: height
        position: 'absolute'
        left: left
        top: top
      }).slideDown()

  ###*
  #Set node position
  #
  ###
  _setPosition: (root, hostView, target, options) ->
    className = "cross-topology-node"
    nodeId = "cross_topology_node_id_#{hostView[root].id}"
    if not angular.element("##{nodeId}").length
      node = angular.element("<div></div>")
      node.addClass(className)
      if hostView[root].name
        name = hostView[root].name.split(".")[0]
        if name.length > 15
          name = "#{name.substr(0,12)}..."
        node.html "<div class='content'>#{name}</div>"
      node.attr({
        id: "#{nodeId}"
        nodeId: hostView[root].id
        title: hostView[root].name
      }).appendTo target
    else
      node = angular.element("##{nodeId}")
    width = $cross.topology._NODE_.width
    height = $cross.topology._NODE_.height
    distanceX = $cross.topology._DISTANCE_.X
    distanceY = $cross.topology._DISTANCE_.Y
    node.addClass("cross-topology-#{hostView[root].type}")
        .addClass("cross-topology-element")
    top = (hostView[root].depth - 1) * (height + distanceY)
    children = hostView[root].children
    notShowChildren = hostView[root].not_show_children
    joinNodeType = $cross.topology._JOIN_NODE_TYPE_
    if not children || not children.length || notShowChildren
      left = (options.left - 1) * (width + distanceX)
      if children && hostView[root].type in joinNodeType
        options =
          top: top
          left: left + $cross.topology._NODE_.width
          id: "cross_topology_node_tip_id_#{hostView[root].id}"
          nodeId: hostView[root].id
          number: hostView[root].running_vms || children.length
        $cross.topology._addNodeTip options, target
    else
      len = hostView[root].children.length
      firstChildID = hostView[hostView[root].children[0]].id
      lastChildID = hostView[hostView[root].children[len - 1]].id
      firstNodeID = "cross_topology_node_id_#{firstChildID}"
      lastNodeID = "cross_topology_node_id_#{lastChildID}"
      firstChild = angular.element("##{firstNodeID}")
      lastChild = angular.element("##{lastNodeID}")
      left = parseInt(lastChild.attr("left"))
      left = (left + parseInt(firstChild.attr("left"))) / 2
    if hostView[root].type in joinNodeType && children
      options =
        left: left + $cross.topology._NODE_.width / 2
        top: top + $cross.topology._NODE_.height
        id: "cross_topology_line_join_id_#{hostView[root].id}"
        nodeId: hostView[root].id
        expend: hostView[root].not_show_children
      $cross.topology._addLineJoin options, target

    if hostView[root].type == $cross.topology._NODE_TYPE_.root
      height = $cross.topology._NODE_.root.height
      width = $cross.topology._NODE_.root.width
      left -= (width - $cross.topology._NODE_.width) / 2
      top -= height - $cross.topology._NODE_.height
    top += height - $cross.topology._NODE_.height
    node.css({width: width, height: height})
      .attr({left: left, top: top, display: "block"})

  ###*
  # Set _index as 0
  #
  ###
  _clearIndex: (hostView) ->
    for key of hostView
      hostView[key]._index = 0
    hostView

  ###*
  # Clear Descendant.
  #
  ###
  _hideDescendant: (root, hostView) ->
    if not hostView[root].children
      return
    line = angular.element("#cross_topology_line_id_#{root}")
    line.fadeOut()
    joinId = "cross_topology_line_join_id_#{hostView[root].id}"
    angular.element("##{joinId}").hide()
    tipId = "cross_topology_node_tip_id_#{hostView[root].id}"
    angular.element("##{tipId}").hide()
    for child in hostView[root].children
      childId = "cross_topology_node_id_#{hostView[child].id}"
      childNode = angular.element("##{childId}")
      childNode.fadeOut().attr("display", "none")
      $cross.topology._hideDescendant child, hostView

  ###*
  # Initial display level
  #
  ###
  _initialDisplayLevel: (hostView) ->
    # check hosts.
    counter_hosts = 0
    for nodeId of hostView
      if hostView[nodeId].type == $cross.topology._NODE_TYPE_.host
        counter_hosts += 1
    if counter_hosts > $cross.topology._MAX_SAME_GENERATION_NODES_
      for nodeId of hostView
        if hostView[nodeId].type == $cross.topology._NODE_TYPE_.cluster
          hostView[nodeId].not_show_children = true
      return hostView
    # check vms.
    counter_vms = 0
    for nodeId of hostView
      if hostView[nodeId].type == $cross.topology._NODE_TYPE_.vm
        counter_vms += 1
    if counter_vms > $cross.topology._MAX_SAME_GENERATION_NODES_
      for nodeId of hostView
        if hostView[nodeId].type == $cross.topology._NODE_TYPE_.host
          hostView[nodeId].not_show_children = true
      return hostView
    return hostView

  ###*
  #
  #
  ###
  _handleHide: (root, hostView) ->
    children = hostView[root].children
    if not children or not children.length
      return hostView
    for child in children
      if hostView[child].not_show_children == undefined
        hostView[child].not_show_children = true
    return hostView

  ###*
  # Here, I use postorder traversal to draw host topology.
  # First, set node position and draw link line.
  # Algorithm as:
  #   1 Loop:
  #   2 If root node has not parent, set depth 1
  #     else depth +1.
  #   3 If show node children or node is leaf, set node position.
  #     Set leaf counter +1, pop node and continue
  #   4 If not node _index, set children node index 0.
  #   5 If _index < node children length, set _index +1 and
  #     push node . Otherwise, set node position, draw link
  #     line and pop node as current node.
  # Second, show node from root to leaves.
  # Third, set container size.
  # Last, set node action(hide or display children nodes).
  #
  # @params hostView: {object}, node list.
  #   Options of hostView item:
  #     `id`: Unique node id.
  #     `name`: Node name.
  #     `parent`: Optional, parent id.
  #     `type`: Node type(root, cluster, host, vm).
  #     `children`: Optional, children id list.
  #     `not_show_children`: Optional, wether not show children node.
  #     `running_vms`: Optional, optional key only for host node.
  #
  # @params target: {jQuery object}, host topology container.
  # @params options: {object}, self define options.
  ###
  _drawTopology: (hostView, target, options) ->
    root = "root"
    options = options || {}
    copyView = []
    options.left = 0
    maxDepth = 1
    loop
      if not hostView[root]
        break if copyView.length == 0
        root = copyView.pop()
        continue
      if not hostView[root].parent
        hostView[root].depth = 1
      else
        if hostView[hostView[root].parent].depth > maxDepth
          maxDepth = hostView[hostView[root].parent].depth
        hostView[root].depth = hostView[hostView[root].parent].depth + 1
      notShowChildren = hostView[root].not_show_children
      children = hostView[root].children
      if not children || not children.length || notShowChildren
        options.left += 1
        $cross.topology._setPosition root, hostView, target, options
        break if copyView.length == 0
        root = copyView.pop()
        continue
      if hostView[root]._index == undefined
        hostView[root]._index = 0
      if hostView[root]._index < hostView[root].children.length
        queue_index = hostView[root]._index
        copyView.push(root)
        hostView[root]._index += 1
        root = hostView[root].children[queue_index]
      else
        $cross.topology._setPosition root, hostView, target, options
        $cross.topology._drawLink root, hostView, target, options
        break if copyView.length == 0
        root = copyView.pop(root)

    containerH = maxDepth * $cross.topology._DISTANCE_.Y
    containerH += (maxDepth + 1) * $cross.topology._NODE_.height
    containerW = (options.left - 1) * $cross.topology._DISTANCE_.X
    containerW += options.left * $cross.topology._NODE_.width
    target.css({
      width: containerW + $cross.topology._DISTANCE_.X
      height: containerH + $cross.topology._DISTANCE_.Y
    })

    if target.data("clickId")
      clkId = "cross_topology_node_id_#{target.data('clickId')}"
      clkEle = angular.element "##{clkId}"
      scrollLeft = target.scrollLeft()
      prePosition = parseInt(clkEle.css("left"))
      deltaLeft = parseInt(clkEle.attr("left")) - prePosition
      target.scrollLeft(deltaLeft + scrollLeft)
      angular.element(".cross-topology-node").each ->
        $this = angular.element(@)
        if $this.css("left") != "auto"
          eleLeft = parseInt($this.css("left"))
          $this.css("left", "#{eleLeft+deltaLeft}px")

    angular.element(".cross-topology-node").each ->
      $this = angular.element(@)
      if $this.css("left") == "auto"
        $this.css({
          left: "#{$this.attr('left')}px"
          top: "#{$this.attr('top')}px"
        }).slideDown()
      else
        $this.css({
          display: $this.attr("display")
        }).animate({
          left: "#{$this.attr('left')}px"
          top: "#{$this.attr('top')}px"
        })

    angular.element(".cross-topology-line-join").unbind("click")
    angular.element(".cross-topology-node-tip").unbind("click")
    target.data("hostView", hostView)
    container = target
    clickHandle = ->
      $this = angular.element(@)
      id = $this.attr("nodeId")
      hostView = container.data("hostView")
      vms = hostView[id].running_vms || hostView[id].children.length
      if not vms
        return

      hostView = $cross.topology._clearIndex hostView
      if not hostView[id].children
        hostView[id].children = []
      # Load vms for specific host.
      if hostView[id].running_vms && not hostView[id].children.length
        vms = $.ajax({
          type: "GET"
          url: "#{$CROSS.settings.serverURL}/servers"
          data:
            host: hostView[id].name
          dataType: "json"
          async: false
        }).responseText
        vms = JSON.parse(vms)
        for vm in vms.data
          hostView["vm_#{vm.id}"] =
            type: "vm"
            children: []
            id: "vm_#{vm.id}"
            parent: id
            name: vm.name
          hostView[id].children.push("vm_#{vm.id}")
        delete hostView[id].running_vms
      if hostView[id].not_show_children == true
        hostView[id].not_show_children = false
        hostView = $cross.topology._handleHide id, hostView
        angular.element("#cross_topology_node_tip_id_#{id}").hide()
        angular.element("#cross_topology_line_join_id_#{id}").show()
      else
        hostView[id].not_show_children = true
        $cross.topology._hideDescendant id, hostView
        angular.element("#cross_topology_node_tip_id_#{id}").show()
        angular.element("#cross_topology_line_join_id_#{id}").hide()

      container.data "clickId", id

      $cross.topology._drawTopology hostView, container

    angular.element(".cross-topology-line-join").bind "click", clickHandle
    angular.element(".cross-topology-node-tip").bind "click", clickHandle

  ###*
  # Draw host view.
  #
  ###
  drawHostView: (hostView, target, options) ->
    if not hostView["root"]
      console.log "no root node!!"
      return
    options = options || {}

    if options.type == "star"
      $cross.topology._drawStartTopological hostView, target
    else
      hostView = $cross.topology._initialDisplayLevel hostView
      $cross.topology._drawTopology hostView, target, options

  _drawStartTopological: (hostView, target) ->
    $cross.topology._setRootPos "root", hostView, target
    ctn_cluster = 0
    for cluster in hostView["root"].children
      $cross.topology._setClusterPos cluster, hostView, target, ctn_cluster
      hst_counter = 0
      for host in hostView[cluster].children
        $cross.topology._setHostPos host, hostView, target, hst_counter
        hst_counter += 1
      #$cross.topology._line cluster, hostView, target
      $cross.topology._circle cluster, hostView, target
      ctn_cluster += 1

    $root = angular.element ".cross-topology-root"
    $root.css("display", "block").animate {
      left: "#{$root.attr('left')}"
      top: "#{$root.attr('top')}"
    }, ->
      $clusters = angular.element ".cross-topology-cluster"
      ctn = $clusters.length
      $clusters.each ->
        $clu = angular.element @
        $clu.css("display", "block").animate {
          left: "#{$clu.attr('left')}px"
          top: "#{$clu.attr('top')}px"
        }, ->
          ctn -= 1
          if ctn == 0
            $hosts = angular.element ".cross-topology-host"
            $hosts.each ->
              $ho = angular.element @
              $ho.css("display", "block").animate({
                left: "#{$ho.attr('left')}px"
                top: "#{$ho.attr('top')}px"
              })
           angular.element(".cross-topology-line").show()

    target.css({
      width: "500px"
      height: "500px"
    })

  _setRootPos: (root, hostView, target) ->
    $node = angular.element "<div></div>"
    $node.addClass "cross-topology-root"
    $node.addClass "cross-topology-node"
    $node.css({
      width: "50px"
      height: "50px"
    }).attr({
      left: 200
      top: 200
      id: "cross_topology_node_id_#{hostView[root].id}"
    }).appendTo target

  _setClusterPos: (root, hostView, target, ctn) ->
    $node = angular.element "<div></div>"
    $node.addClass "cross-topology-cluster"
    $node.addClass "cross-topology-node"
    parent = hostView[hostView[root].parent]
    $parent = angular.element "#cross_topology_node_id_#{parent.id}"
    len = parent.children.length
    left = 80 * Math.cos 2 * Math.PI * ctn / len
    top = 80 * Math.sin 2 * Math.PI * ctn / len
    left += $parent.width() / 2 - 15
    top += $parent.height() / 2 - 15
    $node.css({
      width: "30px"
      height: "30px"
      left: "#{$parent.attr('left')}px"
      top: "#{$parent.attr('top')}px"
      border: "1px solid #aaa"
      "border-radius": "15px"
    }).attr({
      rnd: 2 * Math.PI * ctn / len
      left: left + parseInt($parent.attr("left"))
      top: top + parseInt($parent.attr("top"))
      id: "cross_topology_node_id_#{hostView[root].id}"
    }).appendTo target

  _setHostPos: (root, hostView, target, ctn) ->
    $node = angular.element "<div></div>"
    $node.addClass "cross-topology-host"
    $node.addClass "cross-topology-node"
    parent = hostView[hostView[root].parent]
    $parent = angular.element "#cross_topology_node_id_#{parent.id}"
    len = parent.children.length
    rnd = parseFloat $parent.attr("rnd")
    left = 30 * Math.cos 2 * Math.PI * ctn / len + rnd
    top = 30 * Math.sin 2 * Math.PI * ctn / len + rnd
    left += $parent.width() / 2 - 8
    left += 80 * Math.cos rnd
    top += $parent.height() / 2 - 8
    top += 80 * Math.sin rnd
    $node.css({
      width: "16px"
      height: "16px"
      left: "#{$parent.attr('left')}px"
      top: "#{$parent.attr('top')}px"
    }).attr({
      left: left + parseInt($parent.attr("left"))
      top: top + parseInt($parent.attr("top"))
      id: "cross_topology_node_id_#{hostView[root].id}"
    }).appendTo target

  _line: (root, hostView, target, ctn) ->
    XMLNS = 'xmlns="http://www.w3.org/2000/svg"'
    VERSION = 'version="1.1"'
    STROKE_WIDTH = 2

    lineStr = "<svg class='cross-topology-line' #{XMLNS} #{VERSION}>"

    $this = angular.element "#cross_topology_node_id_#{hostView[root].id}"
    left = parseInt($this.attr("left"))
    top = parseInt($this.attr("top"))
    rnd = parseFloat $this.attr("rnd")
    left += 35 * Math.cos rnd
    top += 35 * Math.sin rnd

    width = 30
    toX = 10 * Math.cos rnd
    toY = 10 * Math.sin rnd

    d = "M#{10-toX} #{10-toY} L#{10+toX} #{10+toY}"
    path = "<path d='#{d}' />"
    lineStr += path + "</svg>"
    $line = angular.element lineStr

    $line.css({
      width: "20px"
      height: "20px"
      left: "#{left}px"
      top: "#{top}px"
      display: "block"
      position: "absolute"
    }).attr({
      left: left
      top: top
      id: "cross_topology_line_id_#{hostView[root].id}"
    }).appendTo target

  _circle: (root, hostView, target) ->
    XMLNS = 'xmlns="http://www.w3.org/2000/svg"'
    VERSION = 'version="1.1"'
    STROKE_WIDTH = 2

    lineStr = "<svg class='cross-topology-line' #{XMLNS} #{VERSION}>"

    thisId = "cross_topology_node_id_#{hostView[root].id}"
    $this = angular.element "##{thisId}"
    left = parseInt($this.attr("left"))
    top = parseInt($this.attr("top"))
    rnd = parseFloat $this.attr("rnd")
    left += 80 * Math.cos rnd
    top += 80 * Math.sin rnd
    left -= $this.width() / 2
    top -= $this.height() / 2

    x = "cx='31'"
    y = "cy='31'"
    r = "r='30'"
    fill = "fill='none'"
    stroke="stroke='#aaa'"
    strokeWidth="stroke-width='1'"
    path = "<circle #{x} #{y} #{r} #{fill} #{stroke} #{strokeWidth} />"
    lineStr += path + "</svg>"
    $line = angular.element lineStr

    $line.css({
      width: "62px"
      height: "62px"
      left: "#{left}px"
      top: "#{top}px"
      display: "none"
      position: "absolute"
    }).attr({
      left: left
      top: top
      id: "cross_topology_circle_id_#{hostView[root].id}"
    }).appendTo target
