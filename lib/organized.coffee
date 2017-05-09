{CompositeDisposable, Directory, Point} = require 'atom'
fs = require 'fs'
{dialog} = require('electron')
moment = require 'moment'

CodeBlock = require './codeblock'
#GoogleCalendar = require './google-calendar'
OrganizedToolbar = require './toolbar'
OrganizedView = require './organized-view'
SidebarView = require './sidebar-view'
Star = require './star'
Table = require './table'
Todo = require './sidebar-items'

module.exports =
  organizedView: null
  modalPanel: null
  subscriptions: null
  levelStyle: 'spaces'
  indentSpaces: 2
  createStarsOnEnter: true
  autoSizeTables: true
  organizedToolbar: null
  useBracketsAroundTodoTags: true

  config:
    levelStyle:
      title: 'Level Style'
      description: 'If you indent a star/bullet point, how should it be indented by default?'
      type: 'string'
      default: 'whitespace'
      enum: [
        {value: 'whitespace', description: 'Sublevels are created by putting spaces or tabs (based on your editor tabType setting) in front of the stars'}
        {value: 'stacked', description: 'Sublevels are created using multiple stars.  For example, level three of the outline would start with ***'}
      ]

    autoCreateStarsOnEnter:
      type: 'boolean'
      default: true

    useBracketsAroundTodoTags:
      type: 'boolean'
      default: true
      description: "When created TODO or DONE tags, prefer [TODO] over TODO and [DONE] over DONE"

    autoSizeTables:
      type: 'boolean'
      default: false
      description: "(Not Ready for Prime Time) If you are typing in a table, automatically resize the columns so your text fits."

    enableToolbarSupport:
      type: 'boolean'
      default: true
      description: "Show a toolbar using the tool-bar package if that package is installed"

    searchDirectories:
      type: 'array'
      title: 'Predefined search directories / files'
      description: 'Directories and/or files where we will look for organized files when building todo lists, agendas, or searching.  Separate multiple files or directories with a comma'
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
          @sidebar.refreshAll()

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
    #@subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:encryptBuffer': (event) => @encryptBuffer(event) }))

    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:toggleBold': (event) => @toggleBold(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:toggleUnderline': (event) => @toggleUnderline(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:toggleHeading': (event) => @toggleHeading(event) }))

    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:makeCodeBlock': (event) => @makeCodeBlock(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:makeResultBlock': (event) => @makeResultBlock(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:makeLink': (event) => @makeLink(event) }))

    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:refreshTodos': (event) => @sidebar.refreshTodos() }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:refreshAgenda': (event) => @sidebar.refreshAgendaItems() }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:scheduleItem': (event) => @scheduleItem(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:deadlineItem': (event) => @deadlineItem(event) }))

    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:archiveSubtree': (event) => @archiveSubtree(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:archiveToClipboard': (event) => @archiveToClipboard(event) }))
    #@subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:importTodaysEvents': (event) => GoogleCalendar.importTodaysEvents() }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:increasePriority': (event) => @increasePriority(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:decreasePriority': (event) => @decreasePriority(event) }))

    @subscriptions.add atom.config.observe 'organized.autoCreateStarsOnEnter', (newValue) => @createStarsOnEnter = newValue
    @subscriptions.add atom.config.observe 'organized.levelStyle', (newValue) => @levelStyle = newValue
    @subscriptions.add atom.config.observe 'organized.autoSizeTables', (newValue) => @autoSizeTables = newValue
    @subscriptions.add atom.config.observe 'editor.tabLength', (newValue) => @indentSpaces = newValue
    @subscriptions.add atom.config.observe 'organized.useBracketsAroundTodoTags', (newValue) => @useBracketsAroundTodoTags = newValue

    @sidebar = new SidebarView()
    @sidebar.activate(@subscriptions)

    if not @organizedToolbar
      @organizedToolbar = new OrganizedToolbar()
      @organizedToolbar.activate(@subscriptions)
      @organizedToolbar.setSidebar(@sidebar)

  archiveSubtree: (event) ->
    @_archiveSubtree(false)

  archiveToClipboard: (event) ->
    archiveText = @_archiveSubtree(true)
    atom.clipboard.write(archiveText)

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

        startMatch = /^(\s*)[\|\+]/.exec(line)
        endMatch = /[\|\+](\s*$)/.exec(line)
        if startMatch and endMatch
          # console.log("startMatch: #{startMatch}, endMatch: #{endMatch}")
          dashCount = endMatch.index-startMatch.index-startMatch[0].length
          editor.insertText("+#{'-'.repeat(dashCount)}+")

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

  deadlineItem: (event) ->
    @_addMarkerDate("DEADLINE")

  decreasePriority: () ->
    @_changePriority(false)

  executeCodeBlock: () ->
    if editor = atom.workspace.getActiveTextEditor()
      if position = editor.getCursorBufferPosition()
        codeblock = new CodeBlock(position.row)
        codeblock.execute()
      else
        atom.notifications.error("Unable to find code block")

  handleEvents: (editor) ->
    tableChangeSubscription = editor.onDidChange (event) =>
      @tableChange(event)
    tableStoppedChangingSub = editor.onDidStopChanging (event) =>
      @tableStoppedChanging(event)
    editorDestroySubscription = editor.onDidDestroy =>
      tableStoppedChangingSub.dispose()

    # @subscriptions.add(tableChangeSubscription)
    @subscriptions.add(tableStoppedChangingSub)
    @subscriptions.add(editorDestroySubscription)

  increasePriority: () ->
    @_changePriority(true)

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
          spaceCount = star.startTodoCol - star.starCol
          indent = @_levelWhitespace(star, editor).repeat(star.indentLevel) + " ".repeat(spaceCount)
          # console.log("spaceCount: #{spaceCount}, indentLevel: #{star.indentLevel}, levelWhiteSpace='#{@_levelWhitespace(star, editor)}'")
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
            if not star or nextStar.indentLevel > star.indentLevel
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

  scheduleItem: (event) ->
    @_addMarkerDate("SCHEDULED")

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
          editor.setTextInBufferRange([[star.startRow, star.startTodoCol], [star.startRow, star.startTextCol]], " [TODO] ")

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
          editor.setTextInBufferRange([[star.startRow, star.whitespaceCol], [star.startRow, star.startTextCol]], " [DONE] ")

  tableChange: (event) ->
    if not @autoSizeTables
      return

    if editor = atom.workspace.getActiveTextEditor()
      scopes = editor.getLastCursor().getScopeDescriptor().getScopesArray()
      if 'row.table.organized' in scopes or 'border.table.organized' in scopes
        table = new Table(editor)
        return unless table.found?
        # Getting closer, but not there yet.
        #table.normalizeRowSizes()

  tableStoppedChanging: (event) ->
    return unless @autoSizeTables
    # if editor = atom.workspace.getActiveTextEditor()
    #   scopes = editor.getLastCursor().getScopeDescriptor().getScopesArray()
    #   if 'row.table.organized' in scopes or 'border.table.organized' in scopes
    #     console.log("Stopped changing")

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
          if match = line.match(/\s*([\-\+\*]+|\d+.) (\[(TODO)\]|\wTODO\w) /)
            replacement = if match[2].includes('[') then " [DONE] " else " DONE "
            editor.setTextInBufferRange([[star.startRow, star.whitespaceCol], [star.startRow, star.startTextCol]], replacement)
          else if (line.match(/\s*([\-\+\*]+|\d+.) ((\[(COMPLETED|DONE)\])|\w(COMPLETED|DONE)\w) /))
            editor.setTextInBufferRange([[star.startRow, star.whitespaceCol], [star.startRow, star.startTextCol]], " ")
          else
            replacement = if @useBracketsAroundTodoTags then " [TODO] " else " TODO "
            editor.setTextInBufferRange([[star.startRow, star.whitespaceCol], [star.startRow, star.startTextCol]], replacement)

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
                if not line
                  continue
                else if line.match("^  ")
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
          else
            editor.outdentSelectedRows()

  _addMarkerDate: (dateType) ->
    if editor = atom.workspace.getActiveTextEditor()
      visited = {}
      d = new Date()
      df = new Intl.DateTimeFormat('en-US', {weekday: 'short'})
      dow = df.format(d)
      @_withAllSelectedLines editor, (position, selection) =>
          if visited[position.row]
            return

          if star = @_starInfo(editor, position)
            for i in [star.startRow..star.endRow]
              visited[i] = true

            editor.transact 1000, () =>
              originalPosition = editor.getCursorBufferPosition()

              # Now add the marker
              newText = "\n" + " ".repeat(star.startTodoCol) + "#{dateType}: <#{@_getISO8601Date(d)} #{dow}>"
              col = editor.lineTextForBufferRow(star.startRow).length
              editor.setTextInBufferRange([[star.startRow, col+1], [star.startRow, col+1]], newText)

  _archiveSubtree: (outputToString) ->
    if editor = atom.workspace.getActiveTextEditor()
      visited = {}

      baseArchiveLevel = null
      stars = []

      # If there are multiple selections, this could span multiple subtrees.  Calculate
      # the total size of the tree first.  One possible problem is that we aren't going
      # to have properties for each of the subtrees when we archive.
      @_withAllSelectedLines editor, (position, selection) =>
        if visited[position.row]
          return

        # Mark all lines in subtree as visited
        visited[position.row] = true

        if not star = @_starInfo(editor, position)
          return

        # Capture the first star, so we know how deeply to indent the properties
        if not baseArchiveLevel
          baseArchiveLevel = star.indentLevel

        if star.indentLevel == baseArchiveLevel
          # We need to put properties on this level too, otherwise we won't be able to unarchive it.
          stars.push(star)

        endOfSubtree = star.getEndOfSubtree()
        for line in [star.startRow..endOfSubtree]
          visited[line] = true

      # Now act on those lines
      editor.transact 2000, () =>
        textToInsertIntoArchiveFile = ""
        rangeToDelete = null

        # Iterate backwards so we don't change the line number of stars.
        # Collect the text to delete and the ranges that we are deleting.
        for star in stars by -1
          startOfSubtree = star.startRow
          endOfSubtree = star.getEndOfSubtree()
          startTodoCol = star.startTodoCol

          # Be careful to support selecting out of the end of a file
          if endOfSubtree == editor.getLastBufferRow()
            lastCol = editor.lineTextForBufferRow(endOfSubtree).length
          else
            endOfSubtree += 1
            lastCol = 0

          archiveText = editor.lineTextForBufferRow(startOfSubtree) + '\n'
          archiveText += ' '.repeat(startTodoCol) + ':PROPERTIES:' + '\n'
          archiveText += ' '.repeat(startTodoCol) + ':ARCHIVE_TIME: ' + moment().format('YYYY-MM-DD ddd HH:mm') + '\n'
          if path = editor.getPath()
            archiveText += ' '.repeat(startTodoCol) + ':ARCHIVE_FILE: ' + path + "\n"
          archiveText += ' '.repeat(startTodoCol) + ':END:' + "\n"

          # If end is the same as the beginning, we've already gotten all of the text
          if endOfSubtree > startOfSubtree
            archiveText += editor.getTextInBufferRange([[startOfSubtree+1, 0], [endOfSubtree, lastCol]])

          if textToInsertIntoArchiveFile isnt ''
            textToInsertIntoArchiveFile = archiveText + textToInsertIntoArchiveFile
          else
            textToInsertIntoArchiveFile = archiveText

          starRangeToDelete = [[startOfSubtree, 0], [endOfSubtree, lastCol]]

          # Increase the total range we are deleting to encompass this star too
          if not rangeToDelete
            rangeToDelete = starRangeToDelete
          # Is this later than our selection to delete?
          if starRangeToDelete[1][0] > rangeToDelete[1][0]
            rangeToDelete[1] = starRangeToDelete[1]
          # Is this earlier than our earliest selection to delete?
          if starRangeToDelete[0][0] < rangeToDelete[0][0]
            rangeToDelete[0] = starRangeToDelete[0]

        # If there is actually something to archive, do that now
        if rangeToDelete
          if outputToString
            editor.setTextInBufferRange(rangeToDelete, '')
            return textToInsertIntoArchiveFile.trimLeft()
          else
            if not archiveFilename = editor.getPath() + '_archive'
              archiveFilename = dialog.showSaveDialog({title: 'Archive filename', message: 'Choose the file where this content will be moved to'})
              if not archiveFilename
                return

            fs.stat archiveFilename, (err, stat) ->
              if err == fs.ENOENT or stat.size == 0
                textToInsertIntoArchiveFile = textToInsertIntoArchiveFile.trimLeft()
              fs.appendFile archiveFilename, textToInsertIntoArchiveFile, (err) ->
                if err
                  atom.notifications.addError("Unable to archive content due to error: " + err)
                else
                  editor.setTextInBufferRange(rangeToDelete, '')

  _changePriority: (up) ->
    if editor = atom.workspace.getActiveTextEditor()
      visited = {}
      editor.transact 1000, () =>
        @_withAllSelectedLines editor, (position, selection) =>
          if visited[position.row]
            return

          if star = @_starInfo(editor, position)
            for i in [star.startRow..star.endRow]
              visited[i] = true

            if up
              star.increasePriority(editor)
            else
              star.decreasePriority(editor)

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
    if star and star.indentType isnt "mixed" and star.indentType isnt "none"
      indentStyle = star.indentType
    else if @levelStyle is "whitespace"
      indentStyle = if editor.getSoftTabs() then "spaces" else "tabs"
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

  _levelWhitespace: (star=null, editor=atom.workspace.getActiveTextEditor()) ->
    if not star
      star = @_starInfo(editor)

    # console.log("star: #{star}, indentType: #{star.indentType}, softTabs: #{editor.getSoftTabs()}")
    if star and star.indentType is "stacked"
      indent = ""
    else if editor.getSoftTabs()
      indent = " ".repeat(@indentSpaces)
    else
      indent = "\t"

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

    if editor
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
