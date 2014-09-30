###*
# class Modal.
#
###
class Modal
  @_NOTE_:
    title: "Modal"
    cancel: "Cancel"
    save: "Save"
    stepPrevious: "Previous"
    stepNext: "Next"
  @_DEFAULT_STEP: 0

  title: "Modal"
  slug: "modal"
  single: true
  steps: []
  parallel: false

  ###*
  # Step next action.
  #
  ###
  nextStep: (scope, options) ->
    step = scope.modal.steps[scope.modal.stepIndex]
    validate = true
    opts = options
    obj = opts.$this
    for field in step.fields
      opts.step = step.slug
      opts.field = field.slug
      if not obj.validator(scope, opts)
        validate = false

    if validate
      scope.modal.stepIndex += 1

  ###*
  # Step previous action.
  #
  ###
  previousStep: (scope, options) ->
    scope.modal.stepIndex -= 1

  jumpStep: (scope, options) ->
    obj = options.$this
    stepIndex = scope.modal.stepIndex
    step = scope.modal.steps[stepIndex]
    opts = options
    validate = true
    for field in step.fields
      opts.step = step.slug
      opts.field = field.slug
      if not obj.validator(scope, opts)
        validate = false
    if validate
      scope.modal.stepIndex = options.index

  ###*
  # close action.
  #
  ###
  close: (scope, options) ->
    scope.$close()

  ###*
  # Validate spect field.
  #
  # Options in options param:
  #   `step`: Optional, step slug.
  #   `field`: field slug.
  #
  # Restrictions in scope:
  #   keys were bult with step, "_", field.
  #
  # Avaliable options restrictions:
  #   `required`: Optional(true|false). If true,
  #               field value cannot be empty.
  #   `number`:   Optional(true|false). If true,
  #               field value must be a number.
  #   `ipv4`:     Optional(true|false). If true,
  #               field value must be a ipv4 address.
  #   `ipv6`:     Optional(true|false). If true,
  #               field value must be a ipv6 address.
  #   `ip`:       Optional(true|false). If true,
  #               field value must be a ip address.
  #   `len`:      Optional(number list). If set, first field
  #               means min length of field value(required).
  #               if second field is set(not required), it
  #               validate max length of field value.
  #   `regex`:    Optional([regular express, notice]).
  #   `func`:     Optional(function (scope, field value)).
  #
  # @params scope: {object}
  # @params options: {object}
  # @return: {bool}
  ###
  validator: (scope, options) ->
    rs = null
    step = options.step
    field = options.field
    sortKey = field

    if step
      val = scope.form[step][field]
      sortKey = "#{step}_#{sortKey}"
    else
      val = scope.form[field]

    # if val is object, we do not need to
    # validate this field.
    if typeof val == "object" && val != null
      return true
    # delete space at the begin or the end.
    val = if not val && val != 0 then "" else val
    val = String(val).replace(/(^\s*)|(\s*$)/g, "")
    restrictions = scope.restrictions[sortKey]

    # if no restrictions, return true.
    if not restrictions
      return true

    # if field not required and is empty, return true.
    if not restrictions.required && val == ""
      if step
        scope.tips[step][field] = rs
      else
        scope.tips[field] = rs
      return true
    else if restrictions.required && val == ""
      rs = _("Cannot be empty.")
      if step
        scope.tips[step][field] = rs
      else
        scope.tips[field] = rs
      return false

    if restrictions.func
      rs = restrictions.func(scope, val)
    else if restrictions.regex
      if not restrictions.regex[0].test(val)
        rs = restrictions.regex[1]
    else
      if restrictions.number
        if not /^[0-9]*$/.test(val)
          rs = _("Must be a number.")
      else if restrictions.ipv4
        IPv4 = "^((25[0-5]|2[0-4]\\d|[01]?\\d\\d?)\.)" +\
               "{3}(25[0-5]|2[0-4]\\d|[01]?\\d\\d?)$"
        reIPv4 = new RegExp(IPv4)
        if not reIPv4.test(val)
          rs = _("Must be IPv4.")
      else if restrictions.ipv6
        reIPv6 = /^([\da-fA-F]{1,4}:){7}[\da-fA-F]{1,4}$/
        if not reIPv6.test(val)
          rs = _("Must be IPv6.")
      else if restrictions.ip
        IPv4 = "^((25[0-5]|2[0-4]\\d|[01]?\\d\\d?)\.)" +\
               "{3}(25[0-5]|2[0-4]\\d|[01]?\\d\\d?)$"
        reIPv4 = new RegExp(IPv4)
        reIPv6 = /^([\da-fA-F]{1,4}:){7}[\da-fA-F]{1,4}$/
        if not reIPv4.test(val) && not reIPv6.test(val)
          rs = _("Must be an IP address.")
      else if restrictions.cidr
        cidr = "^(((\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])\." +\
               "(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])\." +\
               "(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])\." +\
               "(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5]))" +\
               "(\/([0-9]|1[0-9]|2[0-9]|3[0-2]))?(\\r|\\n|\\r\\n)?){1,4}$"
        reCidr = new RegExp(cidr)
        if not reCidr.test(val)
          rs = _("Must be cidr.")

      if not rs && restrictions.len
        len = val.length
        if restrictions.len[0] > len
          rs = _("Length shoud be longer than ") +
               restrictions.len[0]
        else if restrictions.len[1] && restrictions.len[1] < len
          rs = _("Length shoud be shorter than ") +
               restrictions.len[1]

    if step
      scope.tips[step][field] = rs
    else
      scope.tips[field] = rs

    if rs then false else true

  ###*
  # handle form action.
  #
  ###
  _handle: (scope, options) ->
    obj = options.$this
    if not scope.modal.single
      step = scope.modal.steps[scope.modal.stepIndex]
      validate = true
      opts = options
      for field in step.fields
        opts.step = step.slug
        opts.field = field.slug
        if not obj.validator(scope, opts)
          validate = false
    else
      validate = true
      opts = options || {}
      for field in scope.modal.fields
        opts.field = field.slug
        if not obj.validator(scope, opts)
          validate = false

    if validate and obj.handle(scope, options)
      scope.$close()

  ###*
  # This could define by user himself(herself).
  # Default options in options:
  #   `$this`: A allocate Modal object.
  #
  # @return: {bool}
  ###
  handle: (scope, options) ->
    return true

  ###*
  # Initial modal.
  #
  ###
  initial: ($scope, options) ->
    obj = Modal
    # initial note.
    $scope.note = $scope.note || {}
    modal = $scope.note.modal || {}
    for note of obj._NOTE_
      modal[note] = _(obj._NOTE_[note])
    modal.title = _(@title)
    $scope.note.modal = modal
    options = options || {}
    options.$this = @

    # handle close action.
    close = @close
    $scope.close = ->
      close $scope, options

    if not @single
      # handle step next action.
      nextStep = @nextStep
      $scope.stepNext = ->
        nextStep $scope, options
      # handle step previous action.
      previousStep = @previousStep
      $scope.stepPrevious = ->
        previousStep $scope, options

      if @parallel
        jumpStep = @jumpStep
        $scope.jumpStep = (step, index) ->
          opts = options
          opts.step = step
          opts.index = index
          jumpStep $scope, opts

    # handle validator.
    validator = @validator
    $scope.validator = (field, step) ->
      opts = options
      opts.field = field
      opts.step = step
      validator $scope, opts
    # handle save action.
    handle = @_handle
    $scope.handle = ->
      handle $scope, options

    # Initial moal.
    $scope.modal = $scope.modal || {}
    $scope.modal.single = @single
    $scope.modal.parallel = @parallel
    $scope.modal.slug = @slug
    $scope.restrictions = {}
    $scope.form = $scope.form || {}
    $scope.tips = $scope.tips || {}
    if not @single
      $scope.modal.stepIndex = obj._DEFAULT_STEP
      $scope.modal.steps = []

      # initial steps.
      for step in @steps
        stepDetail = @["step_#{step}"]()
        detail =
          slug: step
          name: stepDetail.name
          fields: []
        $scope.form[step] = {}
        $scope.tips[step] = {}
        for field in stepDetail.fields
          if not field.slug
            continue
          $scope.form[step][field.slug] = null
          $scope.tips[step][field.slug] = null
          if field.restrictions
            $scope.restrictions["#{step}_#{field.slug}"] =\
                                         field.restrictions
          detail.fields.push field
        $scope.modal.steps.push detail
    else
      fields = @fields()
      $scope.modal.fields = []
      for field in fields
        if not field.slug
          continue
        $scope.form[field.slug] = null
        $scope.tips[field.slug] = null
        $scope.modal.fields.push field
        if field.restrictions
          $scope.restrictions[field.slug] =\
                          field.restrictions

$cross.Modal = Modal
