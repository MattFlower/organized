{CompositeDisposable, Directory} = require 'atom'
OrganizedView = require './organized-view'

module.exports =
  organizedView: null
  modalPanel: null
  subscriptions: null
  newLevelStyle: 'whitespace'
  indentSpaces: 2

  config:
    levelStyle:
      type: 'string'
      default: 'whitespace'
      enum: [
        {value: 'whitespace', description: 'Sublevels are created by putting spaces or tabs in front of the stars'}
        {value: 'stacked', description: 'Sublevels are created using multiple stars.  For example, level three of the outline would start with ***'}
      ]
    indentSpaces:
      type: 'integer'
      default: 2

  activate: (state) ->
    console.log("Organized is activated")
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

    # Determine how we should new outline depth levels should be created
    @newLevelStyle = atom.config.get('organized.newLevelStyle')
    atom.config.observe 'organized.newLevelStyle', (newValue) =>
      @newLevelStyle = newValue
    @indentSpaces = atom.config.get('editor.tabLength')
    atom.config.observe 'editor.tabLength', (newValue) =>
      @indentSpaces = newValue

  deactivate: () ->
    console.log("Organized is deactivated")
    @modalPanel.destroy()
    @subscriptions.dispose()
    @organizedView.destroy()

  serialize: () ->
    return {
      organizedViewState: @organizedView.serialize()
    }

  indent: (event) ->
    console.log('indent')
    if editor = atom.workspace.getActiveTextEditor()
      position = editor.getCursorBufferPosition()
      if first = @_findPrevStar(editor, position)
        [firstRow, ...] = first
        lastRow = @_findLastRowOfStar(editor, position)

        #We found the lines, now indent
        indent = if @_newLevelStyle == 'whitespace' then " ".repeat(@indentSpaces) else "\t"
        for row in [firstRow..lastRow]
          editor.setTextInBufferRange([[row, 0], [row, 0]], indent)

  unindent: (event) ->
    console.log('unindent!')
    if editor = atom.workspace.getActiveTextEditor()
      position = editor.getCursorBufferPosition()
      if first = @_findPrevStar(editor, position)
        [firstRow, ...] = first
        lastRow = @_findLastRowOfStar(editor, position)

        #Unindent
        indent = if @_newLevelStyle == 'whitespace' then " ".repeat(@indentSpaces) else "\t"
        for row in [firstRow..lastRow]
          line = editor.lineTextForBufferRow(row)
          if line.match("^  ")
            editor.setTextInBufferRange([[row, 0], [row, 2]], "")
          else if line.match("^\\t")
            editor.setTextInBufferRange([[row, 0], [row, 1]], "")


  toggleTodo: (event) ->
    console.log("toggleTodo")
    editor = atom.workspace.getActiveTextEditor()
    if editor
      position = editor.getCursorBufferPosition()
      [row, col] = @_findPrevStar(editor, position)
      line = editor.lineTextForBufferRow(row)

      currentPosition = editor.getCursorBufferPosition()
      if (line.match("\\s*[\\-\\+\\*]+ \\[TODO\\] "))
        deleteStart = line.indexOf("[TODO] ")
        editor.setTextInBufferRange([[row, deleteStart], [row, deleteStart+7]], "[COMPLETED] ")
        editor.setCursorBufferPosition([currentPosition.row, currentPosition.column+5])
      else if (line.match("\\s*[\\-\\+\\*]+ \\[COMPLETED\\] "))
        deleteStart = line.indexOf("[COMPLETED] ")
        editor.setTextInBufferRange([[row, deleteStart], [row, deleteStart+12]], "")
        editor.setCursorBufferPosition([currentPosition.row, currentPosition.column-12])
      else
        insertCol = @_starIndexOf(line)
        editor.setTextInBufferRange([[row, insertCol+1], [row, insertCol+1]], " [TODO]")
        editor.setCursorBufferPosition([currentPosition.row, currentPosition.column+7])

  # Find the current star in terms in buffer coordinates
  # returns [row, column] or
  _findPrevStar: (editor, position) ->
    row = position.row
    line = editor.lineTextForBufferRow(row)
    while !@_starOnLine(line)
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
    row = row+1 until row > editor.getLastBufferRow() or @_starOnLine(line)
    return row - 1

  _starIndexOf: (line) ->
    if starIndex = line.indexOf('*')
      return starIndex
    else if starIndex = line.indexOf('-')
      return starIndex
    else if starIndex = line.indexOf('+')
      return starIndex
    else
      return -1

  _starOnLine: (line) ->
    return line.match("\\s*[\\*-+]")
