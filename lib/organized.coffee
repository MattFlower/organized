{CompositeDisposable, Directory} = require 'atom'
OrganizedView = require './organized-view'

module.exports =
  organizedView: null
  modalPanel: null
  subscriptions: null

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
    @subscriptions.add(atom.commands.add('atom-workspace', { 'organized:toggle': () => @toggle() }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:indent': (event) => @indent(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:unindent': (event) => @unindent(event) }))
    @subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:toggleTodo': (event) => @toggleTodo(event) }))

  deactivate: () ->
    console.log("Organized is deactivated")
    @modalPanel.destroy()
    @subscriptions.dispose()
    @organizedView.destroy()

  serialize: () ->
    return {
      organizedViewState: @organizedView.serialize()
    }

  toggle: () ->
    console.log('Organized was toggled!')
    if @modalPanel.isVisible()
      return @modalPanel.hide()
    else
      return @modalPanel.show()

  indent: (event) ->
    console.log('indent')
    editor = atom.workspace.getActiveTextEditor()
    editor.insertText("  ")

  unindent: (event) ->
    console.log('unindent!')

  toggleTodo: (event) ->
    console.log("toggleTodo")
    editor = atom.workspace.getActiveTextEditor()
    if editor
      position = editor.getCursorBufferPosition()
      row = position.row
      line = editor.lineTextForBufferRow(row)
      while !line.match("\\s*\\*")
        row -= 1
        if (row < 0)
          return
        else
          line = editor.lineTextForBufferRow(row)

      currentPosition = editor.getCursorBufferPosition()
      if (line.match("\\s*\\* \\[TODO\\] "))
        deleteStart = line.indexOf("[TODO] ")
        editor.setTextInBufferRange([[row, deleteStart], [row, deleteStart+7]], "[COMPLETED] ")
        editor.setCursorBufferPosition([currentPosition.row, currentPosition.column+5])
      else if (line.match("\\s*\\* \\[COMPLETED\\] "))
        deleteStart = line.indexOf("[COMPLETED] ")
        editor.setTextInBufferRange([[row, deleteStart], [row, deleteStart+12]], "")
        editor.setCursorBufferPosition([currentPosition.row, currentPosition.column-12])
      else
        insertCol = line.indexOf("*")
        editor.setTextInBufferRange([[row, insertCol+1], [row, insertCol+1]], " [TODO]")
        editor.setCursorBufferPosition([currentPosition.row, currentPosition.column+7])
