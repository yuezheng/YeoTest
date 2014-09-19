# define a namespace $cross
window.$cross =
  # define locale
  locale: {}

  initialLocal: (locale) ->
    transData = $.ajax({
      url: "locale/#{locale}.json"
      type: "GET"
      async: false
    }).responseText
    $cross.locale = JSON.parse(transData)

  initialCentBox: ->
    $ele = angular.element('.cross-frame-main-center')
    topHeight = angular.element('.cross-frame-main-top-tool')
                       .css('height')
    marginTop = parseInt($ele.css("margin-top"))
    windowHeight = angular.element(".cross-frame-left").height()
    $eleHeight = parseInt(windowHeight) - parseInt(topHeight)
    $ele.css({height: $eleHeight - marginTop})

  animateSector: (path, options) ->
    endDegrees = options.endDegrees
    endDegrees = if endDegrees < 360 then endDegrees else 359.999
    new_opts = options
    new_opts.endDegrees = 0
    timeDelta = parseInt(360 * 2 / endDegrees)
    if options.animate
      intervalId = setInterval ->
        new_opts.endDegrees += 2
        if new_opts.endDegrees >= endDegrees
          new_opts.endDegrees = endDegrees
          clearInterval intervalId
        $cross.annularSector path, options
      , timeDelta

  ###* Options:
   # - centerX, centerY: coordinates for the center of the circle
   # - startDegrees, endDegrees: fill between these angles, clockwise
   # - innerRadius, outerRadius: distance from the center
   # - thickness: distance between innerRadius and outerRadius
   #   You should only specify two out of three of the radii and thickness
  ###
  annularSector: (path, options) ->
    opts = $cross.optionsWithDefaults options
    p = [
      [opts.cx + opts.r2 * Math.cos(opts.startRadians),
       opts.cy + opts.r2 * Math.sin(opts.startRadians)],
      [opts.cx + opts.r2 * Math.cos(opts.closeRadians),
       opts.cy + opts.r2 * Math.sin(opts.closeRadians)],
      [opts.cx + opts.r1 * Math.cos(opts.closeRadians),
       opts.cy + opts.r1 * Math.sin(opts.closeRadians)],
      [opts.cx + opts.r1 * Math.cos(opts.startRadians),
       opts.cy + opts.r1 * Math.sin(opts.startRadians)],
    ]

    angleDiff = opts.closeRadians - opts.startRadians
    largeArc = if angleDiff % (Math.PI * 2) > Math.PI then 1 else 0
    cmds = [];
    cmds.push "M#{p[0].join()}"
    cmds.push "A#{[opts.r2,opts.r2,0,largeArc,1,p[1]].join()}"
    cmds.push "L#{p[2].join()}"
    cmds.push "A#{[opts.r1,opts.r1,0,largeArc,0,p[3]].join()}"
    cmds.push "z"
    path.setAttribute 'd', cmds.join(' ')

  optionsWithDefaults: (o) ->
    # Create a new object so that we don't mutate the original
    o2 =
      cx: o.centerX || 0
      cy: o.centerY || 0
      startRadians: (o.startDegrees || 0) * Math.PI / 180
      closeRadians: (o.endDegrees || 0) * Math.PI / 180

    t = if o.thickness != undefined then o.thickness else 100
    if o.innerRadius != undefined
      o2.r1 = o.innerRadius;

    o2.r1 = if o.outerRadius then o.outerRadius - t else 200 -t
    o2.r2 = if o.outerRadius then o.outerRadius else o2.r1 + t
    o2.r1 = if o2.r1 < 0 then 0 else o2.r1
    o2.r2 = if o2.r2 < 0 then 0 else o2.r2
    return o2

$cross.initial = ->
  $cross.initialCentBox()
  window.onresize = ->
    $cross.initialCentBox()

  window._ = (text) ->
    if typeof text != "string"
      return text

    trans = window.$cross.locale[text]
    return if trans then trans else text

$cross.initial()
