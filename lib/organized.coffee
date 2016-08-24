{CompositeDisposable, Directory, Point} = require 'atom'
OrganizedView = require './organized-view'
Star = require './star'

module.exports =
  organizedView: null
  modalPanel: null
  subscriptions: null
  levelStyle: 'spaces'
  indentSpaces: 2
  createStarsOnEnter: true
  lineUpNewTextLinesUnderTextNotStar: true

  config:
    levelStyle:
      type: 'string'
      default: 'spaces'
      enum: [
        {value: 'spaces', description: 'Sublevels are created by putting spaces in front of the stars'}
        {value: 'tabs', description: 'Sublevels are created by putting tabs in front of the stars'}
        {value: 'stacked', description: 'Sublevels are created using multiple stars.  For example, level three of the outline would start with ***'}
      ]
    indentSpaces:
      type: 'integer'
      default: 2

    autoCreateStarsOnEnter:
      type: 'boolean'
      default: true

    lineUpNewTextLinesUnderTextNotStar:
      type: 'boolean'
      default: true

  activate: (state) ->
    atom.themes.requireStylesheet(require.resolve('../styles/organized.less'));

    @organizedView = new OrganizedView(state.organizedViewState)
    @modalPanel = atom.workspace.addModalPanel({
        item: @organizedView.getElement(),
        visible: false
      })

    @subscriptions = new CompositeDisposable()

    # Register command that toggles this view
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:indent': (event) => @indent(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:unindent': (event) => @unindent(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:toggleTodo': (event) => @toggleTodo(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:newLine': (event) => @newLine(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:newStarLine': (event) => @newStarLine(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:insertDate': (event) => @insert8601Date(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:insertDateTime': (event) => @insert8601DateTime(event) }))

    @subscriptions.add atom.config.observe 'organized.autoCreateStarsOnEnter', (newValue) => @createStarsOnEnter = newValue
    @subscriptions.add atom.config.observe 'organized.lineUpNewTextLinesUnderTextNotStar', (newValue) => @lineUpNewTextLinesUnderTextNotStar = newValue
    @subscriptions.add atom.config.observe 'organized.levelStyle', (newValue) => @levelStyle = newValue
    @subscriptions.add atom.config.observe 'editor.tabLength', (newValue) => @indentSpaces = newValue

    #Not sure why I have so much trouble with this particular keymap
    # atom.keymaps.add("/Users/mflower/.atom/packages/organized/keymaps/organized.cson", "shift-enter", 100)

  deactivate: () ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @organizedView.destroy()

  indent: (event) ->
    if star = @_starInfo()
      editor = atom.workspace.getActiveTextEditor()
      indent = if @levelStyle is "stacked" then star.starType else @_indentChars()

      editor.transact 1000, () =>
        for row in [star.startRow..star.endRow]
          editor.setTextInBufferRange([[row, 0], [row, 0]], indent)

  insert8601Date: (event) ->
    d = new Date()

    editor = atom.workspace.getActiveTextEditor()
    editor.insertText(@_getISO8601Date(d))

  insert8601DateTime: (event) ->
    d = new Date()

    editor = atom.workspace.getActiveTextEditor()
    editor.insertText(@_getISO8601Date(d) + "T" + @_getISO8601Time(d))

  # Respond to someone pressing enter.
  # There's some special handling here.  The auto-intent that's built into atom does a good job, but I want the
  # new text to be even with the start of the text, not the start of the star.
  newLine: (event) ->
    if editor = atom.workspace.getActiveTextEditor()
      if star = @_starInfo()
        editor.transact 1000, () =>
          editor.insertNewline()
          indent = @_indentChars().repeat(star.indentLevel) + "  "
          newPosition = editor.getCursorBufferPosition()
          editor.transact 1000, () =>
            editor.setTextInBufferRange([[newPosition.row, 0],[newPosition.row, newPosition.column]], indent)
            editor.setCursorBufferPosition([newPosition.row, indent.length])
      else
        editor.insertNewline()

  newStarLine: (event) ->
    if editor = atom.workspace.getActiveTextEditor()
      # Bail out if the user didn't want any special behavior
      if !@createStarsOnEnter
        editor.insertNewline()
        return

      # If a user hits return and they haven't really done anything on this line,
      # treat it like an unindent.  It seems awkward to add another empty one.
      oldPosition = editor.getCursorBufferPosition()
      line = editor.lineTextForBufferRow(oldPosition.row)
      if line.match(/([\*\-\+]|\d+\.) $/)
        @unindent()
        return

      # If the previous line was entirely empty, it seems like the outline is kind
      # of "done".  Don't try to restart it yet.
      if line.match(/^\s*$/)
        editor.insertNewline()
        return

      star = @_starInfo()

      # Make sure we aren't in the middle of a codeblock
      row = oldPosition.row
      line = editor.lineTextForBufferRow(row)

      minRow = if star then star.startRow else 0
      while row > minRow and not line.match(/^\s*```/)
        row -= 1
        line = editor.lineTextForBufferRow(row)
      if line.match(/^\s*```/)
        # Just add a newline, we're in the middle of a code block
        editor.insertNewline()
        return

      # Figure out where we were so we can use it to figure out where to put the star
      # and what kind of star to use
      # Really hit return now
      editor.transact 1000, () =>
        if star and star.indentLevel >= 0
          editor.insertNewline()

          if oldPosition.column <= star.starCol
            # If the cursor on a column before the star on the line, just insert a newline
            return

          #Create our new text to insert
          newPosition = editor.getCursorBufferPosition()
          if star.starType is 'numbers'
            indent = @_indentChars(star, editor, oldPosition).repeat(star.indentLevel) + star.nextNumber + '. '
            editor.setTextInBufferRange([[newPosition.row, 0], [newPosition.row, Infinity]], indent)

            position = new Point(newPosition.row+1, 0)
            #console.log("newPosition+1: #{position}, last buffer row: #{editor.getLastBufferRow()}")
            while position.row <= editor.getLastBufferRow() and nextStar = @_starInfo(editor, position)
              if nextStar.starType isnt 'numbers' or nextStar.indentLevel isnt star.indentLevel
                break
              #console.log("Position: #{position}, nextStar.startRow: #{nextStar.startRow}, nextStar.endRow: #{nextStar.endRow}")
              #console.log("Replacing #{nextStar.currentNumber} with #{nextStar.nextNumber}")
              editor.setTextInBufferRange([[nextStar.startRow, nextStar.starCol],
                                          [nextStar.startRow, nextStar.starCol+(""+nextStar.currentNumber).length]],
                                          "" + nextStar.nextNumber)
              position = new Point(nextStar.endRow+1, 0)
          else if @levelStyle is "stacked"
            indent = star.starType.repeat(star.indentLevel) + " "
            editor.transact 1000, () =>
              editor.setTextInBufferRange([[newPosition.row, 0],[newPosition.row, newPosition.column]], indent)
              editor.setCursorBufferPosition([newPosition.row, indent.length])
          else
            indent = @_indentChars(star, editor, oldPosition).repeat(star.indentLevel) + star.starType + " "
            editor.transact 1000, () =>
              editor.setTextInBufferRange([[newPosition.row, 0],[newPosition.row, newPosition.column]], indent)
              editor.setCursorBufferPosition([newPosition.row, indent.length])
        else
          editor.insertNewline()

  serialize: () ->
    return {
      organizedViewState: @organizedView.serialize()
    }

  toggleTodo: (event) ->
    editor = atom.workspace.getActiveTextEditor()
    if editor
      position = editor.getCursorBufferPosition()
      if star = @_starInfo()
        line = editor.lineTextForBufferRow(star.startRow)

        currentPosition = editor.getCursorBufferPosition()
        if (line.match(/\s*([\-\+\*]+|\d+.) \[TODO\] /))
          deleteStart = line.indexOf("[TODO] ")
          editor.setTextInBufferRange([[star.startRow, deleteStart], [star.startRow, deleteStart+7]], "[COMPLETED] ")
          editor.setCursorBufferPosition([currentPosition.row, currentPosition.column+5])
        else if (line.match(/\s*([\-\+\*]+|\d+.) \[COMPLETED\] /))
          deleteStart = line.indexOf("[COMPLETED] ")
          editor.setTextInBufferRange([[star.startRow, deleteStart], [star.startRow, deleteStart+12]], "")
          editor.setCursorBufferPosition([currentPosition.row, currentPosition.column-12])
        else
          editor.setTextInBufferRange([[star.startRow, star.whitespaceCol], [star.startRow, star.whitespaceCol]], " [TODO]")
          editor.setCursorBufferPosition([currentPosition.row, currentPosition.column+7])

  unindent: (event) ->
    if editor = atom.workspace.getActiveTextEditor()
      position = editor.getCursorBufferPosition()
      if star = @_starInfo()
        firstRow = star.startRow
        lastRow = star.endRow

        #Unindent
        editor.transact 1000, () ->
          for row in [firstRow..lastRow]
            line = editor.lineTextForBufferRow(row)
            if line.match("^  ")
              editor.setTextInBufferRange([[row, 0], [row, 2]], "")
            else if line.match("^\\t")
              editor.setTextInBufferRange([[row, 0], [row, 1]], "")
            else if match = line.match(/^([\*\-\+]|\d+\.) /)
              editor.setTextInBufferRange([[row, 0], [row, match[0].length]], "")
            else if line.match(/^[\*\-\+]/)
              #Stacked
              editor.setTextInBufferRange([[row, 0], [row, 1]], "")
            else
              #cannot unindent - not sure how to do so

  _getISO8601Date: (date) ->
    year = ("0000" + date.getFullYear()).substr(-4, 4)
    month = ("00" + (date.getMonth() + 1)).substr(-2, 2)
    date = ("00" + date.getDate()).substr(-2, 2)

    "" + year + "-" + month + "-" + date

  _getISO8601Time: (date) ->
    offset = date.getTimezoneOffset()
    if offset is 0
      offsetString = "Z"
    else
      negative = offset < 0;
      offsetHours = ("00" + Math.floor(offset/60)).substr(-2, 2)
      offsetMinutes = ("00" + (offset % 60)).substr(-2, 2)
      offsetString = if negative then "-" else "+"
      offsetString += offsetHours + ":" + offsetMinutes

    hours = ("00" + date.getHours()).substr(-2, 2)
    minutes = ("00" + date.getMinutes()).substr(-2, 2)
    seconds = ("00" + date.getSeconds()).substr(-2, 2)

    "" + hours + ":" + minutes + ":" + seconds + offsetString

  _indentChars: (star=null, editor=atom.workspace.getActiveTextEditor(), position=editor.getCursorBufferPosition()) ->
    #console.log("Editor: #{editor}, Position: #{position}")
    if @levelStyle is "spaces"
      indent = " ".repeat(@indentSpaces)
    else if @levelStyle is "tabs"
      indent = "\t"
    else if @levelStyle is "stacked"
      if not star
        star = @_starInfo()
      indent = star.starType

    return indent

  _starInfo: (editor=atom.workspace.getActiveTextEditor(), position=editor.getCursorBufferPosition()) ->
    # Returns the following info
    # * Start Position of last star
    # * Last line of star
    # * Type of star (*, -, +, number)
    # * Type of whitespace (tabs, spaces, stacked, mixed)
    if not editor
      console.error("Editor is required")
      return
    if not position
      console.error("Position is required")
      return

    # Find the line with the last star.  If you find blank lines or a header, there probably isn't a
    # star for this position
    currentLine = position.row
    star = new Star(currentLine, @indentSpaces)
    if star.startRow >= 0
      return star
    else
      return null
