{CompositeDisposable, Directory} = require 'atom'
OrganizedView = require './organized-view'

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

    @subscriptions.add atom.config.observe 'organized.autoCreateStarsOnEnter', (newValue) => @createStarsOnEnter = newValue
    @subscriptions.add atom.config.observe 'organized.lineUpNewTextLinesUnderTextNotStar', (newValue) => @lineUpNewTextLinesUnderTextNotStar = newValue
    @subscriptions.add atom.config.observe 'organized.levelStyle', (newValue) => @levelStyle = newValue
    @subscriptions.add atom.config.observe 'editor.tabLength', (newValue) => @indentSpaces = newValue

    #Not sure why I have so much trouble with this particular keymap
    atom.keymaps.add("/Users/mflower/.atom/packages/organized/keymaps/organized.cson", "shift-enter", 100)

  deactivate: () ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @organizedView.destroy()

  indent: (event) ->
    if editor = atom.workspace.getActiveTextEditor()
      position = editor.getCursorBufferPosition()
      # console.log("Position: #{position}")
      if first = @_findPrevStar(editor, position)
        # console.log("First: #{first}")
        [firstRow, ...] = first
        lastRow = @_findLastRowOfStar(editor, position)
        # console.log("Last: #{lastRow}")

        if @levelStyle is "stacked"
          indent = @_starType(editor, position)
        else
          indent = @_indentChars(editor, position)

        #We found the lines, now indent
        editor.transact 1000, () =>
          for row in [firstRow..lastRow]
            editor.setTextInBufferRange([[row, 0], [row, 0]], indent)

  # Respond to someone pressing enter.
  # There's some special handling here.  The auto-intent that's built into atom does a good job, but I want the
  # new text to be even with the start of the text, not the start of the star.
  newLine: (event) ->
    if editor = atom.workspace.getActiveTextEditor()
      oldPosition = editor.getCursorBufferPosition()
      if star = @_findPrevStar(editor, oldPosition)
        editor.transact 1000, () =>
          lastRowLevel = @_starLevel(editor, oldPosition)
          editor.insertNewline()
          indent = @_indentChars().repeat(lastRowLevel) + "  "
          newPosition = editor.getCursorBufferPosition()
          editor.setTextInBufferRange([[newPosition.row, 0], [newPosition.row, Infinity]], indent)
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
      if line.match(/[\*\-\+] $/)
        @unindent()
        return

      # If the previous line was entirely empty, it seems like the outline is kind
      # of "done".  Don't try to restart it yet.
      if line.match(/^\s*$/)
        editor.insertNewline()
        return

      # Figure out where we were so we can use it to figure out where to put the star
      # and what kind of star to use
      # Really hit return now
      editor.transact 1000, () =>
        lastRowLevel = @_starLevel(editor, oldPosition)
        if lastRowLevel >= 0
          starType = @_starType(editor, oldPosition)
          # console.log("starType: #{starType}")
          editor.insertNewline()

          #Create our new text to insert
          if @levelStyle is "stacked"
            indent = starType.repeat(lastRowLevel) + " "
          else
            indent = @_indentChars(editor, oldPosition).repeat(lastRowLevel) + starType + " "
          # console.log("Indent: '#{indent}'")
          newPosition = editor.getCursorBufferPosition()
          editor.setTextInBufferRange([[newPosition.row, 0], [newPosition.row, Infinity]], indent)
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
      if prevStar = @_findPrevStar(editor, position)
        [row, col] = prevStar
        line = editor.lineTextForBufferRow(row)

        currentPosition = editor.getCursorBufferPosition()
        if (line.match(/\s*[\-\+\*]+ \[TODO\] /))
          deleteStart = line.indexOf("[TODO] ")
          editor.setTextInBufferRange([[row, deleteStart], [row, deleteStart+7]], "[COMPLETED] ")
          editor.setCursorBufferPosition([currentPosition.row, currentPosition.column+5])
        else if (line.match(/\s*[\-\+\*]+ \[COMPLETED\] /))
          deleteStart = line.indexOf("[COMPLETED] ")
          editor.setTextInBufferRange([[row, deleteStart], [row, deleteStart+12]], "")
          editor.setCursorBufferPosition([currentPosition.row, currentPosition.column-12])
        else
          insertCol = @_starIndexOf(line)
          editor.setTextInBufferRange([[row, insertCol+1], [row, insertCol+1]], " [TODO]")
          editor.setCursorBufferPosition([currentPosition.row, currentPosition.column+7])

  unindent: (event) ->
    if editor = atom.workspace.getActiveTextEditor()
      position = editor.getCursorBufferPosition()
      if first = @_findPrevStar(editor, position)
        [firstRow, ...] = first
        lastRow = @_findLastRowOfStar(editor, position)

        #Unindent
        editor.transact 1000, () ->
          for row in [firstRow..lastRow]
            line = editor.lineTextForBufferRow(row)
            if line.match("^  ")
              editor.setTextInBufferRange([[row, 0], [row, 2]], "")
            else if line.match("^\\t")
              editor.setTextInBufferRange([[row, 0], [row, 1]], "")
            else if line.match(/^[\\*\\+\\-]/)
              editor.setTextInBufferRange([[row, 0], [row, 1]], "")
            else
              #cannot unindent - not sure how to do so

  # Find the current star in terms in buffer coordinates
  # returns [row, column] or
  _findPrevStar: (editor, position) ->
    row = position.row
    line = editor.lineTextForBufferRow(row)
    while !@_starOnLine(line)
      # console.log("No star on #{row}")
      row -= 1
      if (row < 0)
        return null
      else
        line = editor.lineTextForBufferRow(row)

    col = -1
    if line
      col = @_starIndexOf(line)

    if col != -1
      return [row, col]
    else
      return null

  _findLastRowOfStar: (editor, position) ->
    lastGoodRow = position.row
    row = position.row + 1
    line = editor.lineTextForBufferRow(row)
    while row < editor.getLastBufferRow() and not line.match(/(s*[#\-\+\*])|(^$)/)
      row += 1
      line = editor.lineTextForBufferRow(row)

    return row - 1

  _indentChars: (editor, position) ->
    if @levelStyle is "spaces"
      indent = " ".repeat(@indentSpaces)
    else if @levelStyle is "tabs"
      indent = "\t"
    else if @levelStyle is "stacked"
      [starRow, ...] = @_findPrevStar(editor, position)
      indent = @_starType(starRow)
    # console.log("levelStyle is #{@levelStyle}, returning #{indent}")
    return indent

  _starIndexOf: (line) ->
    if (starIndex = line.indexOf('*')) > -1
      return starIndex
    else if (starIndex = line.indexOf('-')) > -1
      return starIndex
    else if (starIndex = line.indexOf('+')) > -1
      return starIndex
    else
      return -1

  _starOnLine: (line) ->
    return line.match(/^\s*[\*\-\+]/)

  _starLevel: (editor, position) ->
    if prevStar = @_findPrevStar(editor, position)
      # console.log("Found prevStar: #{prevStar}")
      [starRow, starIndex] = prevStar
      line = editor.lineTextForBufferRow(starRow)

      levelCount = 0
      if stars = line.match(/([\*\-\+]+)/)
          if stars[1].length > 1
            levelCount = stars[1].length
          else
            levelCount = 0
            index = 0
            indentBySpaceString = " ".repeat(@indentSpaces)
            # console.log("indentSpaces: #{@indentSpaces}")
            while index < starIndex
              # console.log("Index: #{index}")
              if line[index] is '\t'
                # console.log("Found tab character")
                levelCount += 1
                index += 1
              else if line[index..index+@indentSpaces-1] is indentBySpaceString
                # console.log("Found '#{line[index..index+@indentSpaces-1]}'")
                levelCount += 1
                index += @indentSpaces
              else
                # console.log("Found unknown: '#{line[index..index+@indentSpaces-1]}', '#{line[index]}'")
                #Not really sure what to do with this.
                index += 1
            return levelCount
        else
          console.warn("Unexpected result, couldn't find star")
    else
      # console.log("No Prev Star")
      return -1

  _starType: (editor, position) ->
    [starRow, ...] = @_findPrevStar(editor, position)
    line = editor.lineTextForBufferRow(starRow)
    if match = line.match(/^\s*([\*\-\+])/)
      return match[1]
    else
      return ""
