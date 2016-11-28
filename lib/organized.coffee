{CompositeDisposable, Directory, Point} = require 'atom'
OrganizedView = require './organized-view'
Star = require './star'
Table = require './table'
Todo = require './todo'
CodeBlock = require './codeblock'
OrganizedToolbar = require './toolbar'
SidebarView = require './sidebar-view'

module.exports =
  organizedView: null
  modalPanel: null
  subscriptions: null
  levelStyle: 'spaces'
  indentSpaces: atom.config.get('editor.tabLength')
  createStarsOnEnter: true
  autoSizeTables: true
  organizedToolbar: null

  config:
    levelStyle:
      title: 'Level Style'
      description: 'If you indent a star/bullet point, how should it be indented by default?'
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

    autoSizeTables:
      type: 'boolean'
      default: false
      description: "If you are typing in a table, automatically resize the columns so your text fits."

    enableToolbarSupport:
      type: 'boolean'
      default: true
      description: "Show a toolbar using the tool-bar package if that package is installed"

    searchDirectories:
      type: 'array'
      title: 'Organized File Directories'
      description: 'Directories where we will look for organized files when building todo lists, agendas, or searching'
      default: ['','','','','']
      items:
        type: 'string'

    includeProjectPathsInSearchDirectories:
      type: 'boolean'
      default: true
      description: 'Indicates whether we should include the paths for the current project in the search directories'

    searchSkipFiles:
      type: 'array'
      title: 'Organized Partial File Names to Skip'
      description: 'A list of partial file names to skip'
      default: ['', '', '', '', '']
      items:
        type: 'string'

    sidebarVisible:
      type: 'boolean'
      title: "Show Sidebar"
      description: "Sidebar is currently being shown"
      default: false

  activate: (state) ->
    atom.themes.requireStylesheet(require.resolve('../styles/organized.less'));

    @organizedView = new OrganizedView(state.organizedViewState)
    @modalPanel = atom.workspace.addModalPanel({
        item: @organizedView.getElement(),
        visible: false
      })

    @subscriptions = new CompositeDisposable()

    # Set up text editors
    @subscriptions.add atom.workspace.observeTextEditors (editor) =>
      @handleEvents(editor)
      @subscriptions.add editor.onDidSave =>
        if @sidebar and @sidebar.sidebarVisible and editor.getGrammar().name is 'Organized'
          @sidebar.refreshTodos()

    # Register command that toggles this view
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:indent': (event) => @indent(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:unindent': (event) => @unindent(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:setTodo': (event) => @setTodo(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:setTodoCompleted': (event) => @setTodoCompleted(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:toggleTodo': (event) => @toggleTodo(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:newLine': (event) => @newLine(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:newStarLine': (event) => @newStarLine(event) }))

    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:createTable': (event) => @createTable(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:newTableRow': (event) => @newTableRow(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:closeTable': (event) => @closeTable(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:openTable': (event) => @openTable(event) }))

    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:insertDate': (event) => @insert8601Date(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:insertDateTime': (event) => @insert8601DateTime(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:executeCodeBlock': (event) => @executeCodeBlock(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:encryptBuffer': (event) => @encryptBuffer(event) }))

    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:toggleBold': (event) => @toggleBold(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:toggleUnderline': (event) => @toggleUnderline(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:toggleHeading': (event) => @toggleHeading(event) }))

    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:makeCodeBlock': (event) => @makeCodeBlock(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:makeResultBlock': (event) => @makeResultBlock(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:makeLink': (event) => @makeLink(event) }))

    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:refreshTodos': (event) => @sidebar.refreshTodos() }))

    @subscriptions.add atom.config.observe 'organized.autoCreateStarsOnEnter', (newValue) => @createStarsOnEnter = newValue
    @subscriptions.add atom.config.observe 'organized.levelStyle', (newValue) => @levelStyle = newValue
    @subscriptions.add atom.config.observe 'organized.indentSpaces', (newValue) => @indentSpaces = newValue
    @subscriptions.add atom.config.observe 'organized.autoSizeTables', (newValue) => @autoSizeTables = newValue

    @sidebar = new SidebarView()
    @sidebar.activate(@subscriptions)
    @sidebar.refreshTodos()

    if not @organizedToolbar
      @organizedToolbar = new OrganizedToolbar()
      @organizedToolbar.activate(@subscriptions)
      @organizedToolbar.setSidebar(@sidebar)

  closeTable: (event) ->
    if editor = atom.workspace.getActiveTextEditor()
      position = editor.getCursorBufferPosition()

      editor.transact 1000, () ->
        # See if we are on an editor line.  If so, the close will be on the next line
        line = editor.lineTextForBufferRow(position.row)
        if 'border.table.organized' in editor.scopeDescriptorForBufferPosition(position).getScopesArray()
          editor.insertNewline()
        else
          line = editor.lineTextForBufferRow(position.row-1)
          editor.setTextInBufferRange([[position.row, 0], [position.row, position.column]], "")

        startMatch = /^(?<=\s*)[\|\+]/.exec(line)
        endMatch = /[\|\+](?=\s*$)/.exec(line)
        if startMatch and endMatch
          # console.log("startMatch: #{startMatch}, endMatch: #{endMatch}")
          editor.insertText("+#{'-'.repeat(endMatch.index-startMatch.index-1)}+")

  # Callback from tool-bar to create a toolbar
  consumeToolBar: (toolBar) ->
    if not @organizedToolbar
      @organizedToolbar = new OrganizedToolbar()
      @organizedToolbar.activate(@subscriptions)
      @organizedToolbar.setSidebar(@sidebar)

    @organizedToolbar.consumeToolBar(toolBar)

  # Create a skeleton of a table ready for a user to start typing in it.
  createTable: (event) ->
    if editor = atom.workspace.getActiveTextEditor()
      position = editor.getCursorBufferPosition()
      editor.transact 1000, () =>
        if not editor.lineTextForBufferRow(position.row).match(/\s*/)
          editor.insertNewline()
        editor.insertText("+----+")
        editor.insertNewline()
        editor.insertText("| ")
        position = editor.getCursorBufferPosition()
        editor.insertNewline()
        editor.insertText("+----+")
        editor.setCursorBufferPosition(position)

  deactivate: () ->
    @organizedToolbar.deactivate()
    @modalPanel.destroy()
    @subscriptions.dispose()
    @organizedView.destroy()

  executeCodeBlock: () ->
    if editor = atom.workspace.getActiveTextEditor()
      if position = editor.getCursorBufferPosition()
        codeblock = new CodeBlock(position.row)
        codeblock.execute()
      else
        atom.notifications.error("Unable to find code block")

  handleEvents: (editor) ->
    # tableChangeSubscription = editor.onDidChange (event) =>
    #   @tableChange(event)
    tableStoppedChangingSub = editor.onDidStopChanging (event) =>
      @tableStoppedChanging(event)
    editorDestroySubscription = editor.onDidDestroy =>
      tableStoppedChangingSub.dispose()

    # @subscriptions.add(tableChangeSubscription)
    @subscriptions.add(tableStoppedChangingSub)
    @subscriptions.add(editorDestroySubscription)

  indent: (event) ->
    if editor = atom.workspace.getActiveTextEditor()
      visited = {}
      editor.transact 2000, () =>
        @_withAllSelectedLines editor, (position, selection) =>
          if visited[position.row]
            return

          if star = @_starInfo(editor, position)
            for i in [star.startRow..star.endRow]
              visited[i] = true

            indent = if star.indentType is "stacked" then star.starType else @_indentChars()
            indentType = if star.indentType is "none" then star.defaultIndentType else star.indentType
            if star.starType is "numbers"
              if indentType in ['tabs', 'spaces']
                editor.setTextInBufferRange([[star.startRow, star.starCol], [star.startRow, star.whitespaceCol]], '1.')
              else if indentType is 'stacked'
                editor.setTextInBufferRange([[star.startRow, star.whitespaceCol], [star.startRow, star.whitespaceCol]], '.1')

            for row in [star.startRow..star.endRow]
              editor.setTextInBufferRange([[row, 0], [row, 0]], indent)
          else
            editor.indentSelectedRows()

  insert8601Date: (event) ->
    d = new Date()

    editor = atom.workspace.getActiveTextEditor()
    editor.insertText(@_getISO8601Date(d))

  insert8601DateTime: (event) ->
    d = new Date()

    editor = atom.workspace.getActiveTextEditor()
    editor.insertText(@_getISO8601Date(d) + "T" + @_getISO8601Time(d))

  makeCodeBlock: (event) ->
    if editor = atom.workspace.getActiveTextEditor()
      position = editor.getCursorBufferPosition()
      editor.transact 1000, () =>
        if not editor.lineTextForBufferRow(position.row).match(/\s*/)
          editor.insertNewline()
        editor.insertText('```')
        endPosition = editor.getCursorBufferPosition()
        editor.insertNewline()
        editor.insertText('```')
        editor.setCursorBufferPosition(endPosition)

  makeResultBlock: (event) ->
    if editor = atom.workspace.getActiveTextEditor()
      position = editor.getCursorBufferPosition()
      editor.transact 1000, () =>
        if not editor.lineTextForBufferRow(position.row).match(/\s*/)
          editor.insertNewline()
        editor.insertText('```result')
        editor.insertNewline()
        editor.insertText('```')

  makeLink: (event) ->
    if editor = atom.workspace.getActiveTextEditor()
      editor.transact 1000, () =>
        @_withAllSelectedLines editor, (position, selection) =>
          if selection.isEmpty()
            editor.insertText("[]()")
            selection.cursor.moveLeft(3)
          else
            range = selection.getBufferRange()
            if selection.getText().match(/^https?:\/\//)
              editor.setTextInBufferRange([range.end, range.end], ")")
              editor.setTextInBufferRange([range.start, range.start], "[](")
            else
              editor.setTextInBufferRange([range.end, range.end], "]()")
              editor.setTextInBufferRange([range.start, range.start], "[")

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

      # Make sure we aren't in the middle of a codeblock
      row = oldPosition.row
      line = editor.lineTextForBufferRow(row)
      star = @_starInfo()
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
        # If there is a star on the next line, we'll use it's insert level and bullet type
        # We'll keep a reference to the old star because we need it sometimes
        oldStar = star
        if oldPosition.row+1 <= editor.getLastBufferRow()
          if nextStar = @_starInfo(editor, new Point(oldPosition.row+1, oldPosition.col))
            if nextStar.indentLevel > star.indentLevel
              star = nextStar

        if star and star.indentLevel >= 0
          editor.insertNewline()

          if oldPosition.column <= star.starCol
            # If the cursor on a column before the star on the line, just insert a newline
            return

          #Create our new text to insert
          newPosition = editor.getCursorBufferPosition()
          if star.starType is 'numbers'
            # Make sure we use a reference to the old star here so we get the
            editor.setTextInBufferRange([[newPosition.row, 0], [newPosition.row, Infinity]], oldStar.newStarLine())

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
          else
            indent = star.newStarLine()
            editor.transact 1000, () =>
              editor.setTextInBufferRange([[newPosition.row, 0],[newPosition.row, newPosition.column]], indent)
              editor.setCursorBufferPosition([newPosition.row, indent.length])
        else
          editor.insertNewline()

  newTableRow: () ->
    if editor = atom.workspace.getActiveTextEditor()
      oldPosition = editor.getCursorBufferPosition()
      line = editor.lineTextForBufferRow(oldPosition.row)
      if match = line.match(/^\s*(\|[ ]?)/)
        editor.transact 1000, () ->
          editor.insertNewline()
          editor.insertText(match[0])
      else
        editor.insertNewline()

  openTable: (event) ->
    if editor = atom.workspace.getActiveTextEditor()
      currentPosition = editor.getCursorBufferPosition()
      line = editor.lineTextForBufferRow(currentPosition.row)
      if match = line.match(/^(\s*)/)
        editor.insertText("+----+\n#{match[0]}| ")

  serialize: () ->
    return {
      organizedViewState: @organizedView.serialize()
    }

  tableChange: (event) ->
    if not @autoSizeTables
      return

    if editor = atom.workspace.getActiveTextEditor()
      if 'row.table.organized' in editor.getLastCursor().getScopeDescriptor().getScopesArray()
        table = new Table(editor)
        return unless table.found?
        columns = table.findRowColumns()
        return unless columns?

        column = table.currentColumnIndex(columns)
        #Add to end of column so spaces in a table column don't look weird
        indentColumn = columns[column+1]-1
        position = editor.getCursorBufferPosition()
        for row in [table.firstRow..table.lastRow]
          console.log("Row: #{row}, position.row: #{position.row}")
          if row is position.row
            continue
          position = [row, indentColumn]
          scopes = editor.scopeDescriptorForBufferPosition(position).getScopesArray()
          console.log(scopes)
          if 'border.table.organized' in scopes
            editor.setTextInBufferRange([[row, indentColumn],[row, indentColumn]], "-")
          else if 'row.table.organized' in scopes
            editor.setTextInBufferRange([[row, indentColumn],[row, indentColumn]], " ")

  tableStoppedChanging: (event) ->
    return unless @autoSizeTables
    if editor = atom.workspace.getActiveTextEditor()
      scopes = editor.getLastCursor().getScopeDescriptor().getScopesArray()
      if 'row.table.organized' in scopes or 'border.table.organized' in scopes
        console.log(event)

  toggleBold: (event) ->
    if editor = atom.workspace.getActiveTextEditor()
      editor.transact 1000, () =>
        @_withAllSelectedLines editor, (position, selection) =>
          if selection.isEmpty()
            editor.insertText("____")
            selection.cursor.moveLeft(2)
          else
            range = selection.getBufferRange()
            startMarked = editor.getTextInBufferRange([range.start, [range.start.row, range.start.column+2]]) is "__"
            endMarked = editor.getTextInBufferRange([[range.end.row, range.end.column-2], range.end]) is "__"

            if startMarked and endMarked
              editor.setTextInBufferRange([[range.end.row, range.end.column-2], range.end], "")
              editor.setTextInBufferRange([range.start, [range.start.row, range.start.column+2]], "")
            else
              editor.setTextInBufferRange([range.end, range.end], '__')
              editor.setTextInBufferRange([range.start, range.start], "__")

  toggleHeading: (event) ->
    if editor = atom.workspace.getActiveTextEditor()
      editor.transact 1000, () =>
        @_withAllSelectedLines editor, (position, selection) =>
          startChars = editor.getTextInBufferRange([[position.row, 0], [position.row, 4]])
          hashCount = 0
          hashCount +=1 until startChars[hashCount] isnt '#'

          if hashCount is 0
            editor.setTextInBufferRange([[position.row, 0], [position.row, 0]], '# ')
          else if hashCount < 3
            editor.setTextInBufferRange([[position.row, 0], [position.row, 0]], '#')
          else
            charsToDelete = if startChars[3] is ' ' then 4 else 3
            editor.setTextInBufferRange([[position.row, 0], [position.row, charsToDelete]], '')

  setTodo: (event) ->
    if editor = atom.workspace.getActiveTextEditor()
      visited = {}
      startPosition = editor.getCursorBufferPosition()
      startRow = startPosition.row

      @_withAllSelectedLines editor, (position, selection) =>
        if visited[position.row]
          return

        if star = @_starInfo(editor, position)
          for i in [star.startRow..star.endRow]
            visited[i] = true

          line = editor.lineTextForBufferRow(star.startRow)
          editor.setTextInBufferRange([[star.startRow, star.whitespaceCol], [star.startRow, star.startTextCol]], " [TODO] ")

  setTodoCompleted: (event) ->
    if editor = atom.workspace.getActiveTextEditor()
      visited = {}
      startPosition = editor.getCursorBufferPosition()
      startRow = startPosition.row

      @_withAllSelectedLines editor, (position, selection) =>
        if visited[position.row]
          return

        if star = @_starInfo(editor, position)
          for i in [star.startRow..star.endRow]
            visited[i] = true

          line = editor.lineTextForBufferRow(star.startRow)
          editor.setTextInBufferRange([[star.startRow, star.whitespaceCol], [star.startRow, star.startTextCol]], " [COMPLETED] ")

  toggleTodo: (event) ->
    if editor = atom.workspace.getActiveTextEditor()
      visited = {}
      startPosition = editor.getCursorBufferPosition()
      startRow = startPosition.row

      @_withAllSelectedLines editor, (position, selection) =>
        if visited[position.row]
          return

        if star = @_starInfo(editor, position)
          for i in [star.startRow..star.endRow]
            visited[i] = true

          line = editor.lineTextForBufferRow(star.startRow)
          if (line.match(/\s*([\-\+\*]+|\d+.) \[TODO\] /))
            deleteStart = line.indexOf("[TODO] ")
            editor.setTextInBufferRange([[star.startRow, deleteStart], [star.startRow, deleteStart+7]], "[COMPLETED] ")
          else if (line.match(/\s*([\-\+\*]+|\d+.) \[COMPLETED\] /))
            deleteStart = line.indexOf("[COMPLETED] ")
            editor.setTextInBufferRange([[star.startRow, deleteStart], [star.startRow, deleteStart+12]], "")
          else
            editor.setTextInBufferRange([[star.startRow, star.whitespaceCol], [star.startRow, star.whitespaceCol]], " [TODO]")

  toggleUnderline: (event) ->
    if editor = atom.workspace.getActiveTextEditor()
      editor.transact 1000, () =>
        @_withAllSelectedLines editor, (position, selection) =>
          if selection.isEmpty()
            editor.insertText('__')
            selection.cursor.moveLeft(1)
          else
            range = selection.getBufferRange()
            startThree = editor.getTextInBufferRange([range.start, [range.start.row, range.start.column+3]])
            endThree = editor.getTextInBufferRange([[range.end.row, range.end.column-3], range.end])
            # Need to consider situations where there is a bold and an underline
            startMatch = startThree.match(/(_[^_][^_]|___)/)
            endMatch = endThree.match(/([^_][^_]_|___)/)

            if startMatch and endMatch
              editor.setTextInBufferRange([[range.end.row, range.end.column-1], range.end], "")
              editor.setTextInBufferRange([range.start, [range.start.row, range.start.column+1]], "")
            else
              editor.setTextInBufferRange([range.end, range.end], '_')
              editor.setTextInBufferRange([range.start, range.start], "_")

  unindent: (event) ->
    if editor = atom.workspace.getActiveTextEditor()
      visited = {}
      editor.transact 2000, () =>
        @_withAllSelectedLines editor, (position, selection) =>
          if visited[position.row]
            return

          if star = @_starInfo(editor, position)
            for i in [star.startRow..star.endRow]
              visited[i] = true

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
                else if match = line.match(/^([\*\-\+]|(\d+\.)+) /)
                  editor.setTextInBufferRange([[row, 0], [row, match[0].length]], "")
                else if line.match(/^[\*\-\+]/)
                  #Stacked
                  editor.setTextInBufferRange([[row, 0], [row, 1]], "")
                else
                  #cannot unindent - not sure how to do so
          else
            editor.outdentSelectedRows()

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
    if star and star.indentType isnt "mixed"
      indentStyle = star.indentType
    else
      indentStyle = @levelStyle

    if indentStyle is "spaces"
      indent = " ".repeat(@indentSpaces)
    else if indentStyle is "tabs"
      indent = "\t"
    else if indentStyle is "stacked"
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
    star = new Star(currentLine, @indentSpaces, @levelStyle)
    if star.startRow >= 0
      return star
    else
      return null

  _withAllSelectedLines: (editor, callback) ->
    editor = atom.workspace.getActiveTextEditor() unless editor

    if editor = atom.workspace.getActiveTextEditor()
      selections = editor.getSelections()
      for selection in selections
        range = selection.getBufferRange()

        #Adjust for selections that span the whole line
        if range.end.column is 0 and (range.start.column isnt range.end.column or range.start.row isnt range.end.row)
          if line = editor.lineTextForBufferRow(range.end.row-1)
            range.end = new Point(range.end.row-1, line.length-1)

        for i in [range.start.row..range.end.row]
          # Create a virtual position object from the range object
          if i is range.end.row
            position = new Point(i, range.end.col)
          else if i is range.start.row
            position = new Point(i, range.start.col)
          else
            position = new Point(i, 0)

          callback(position, selection)
