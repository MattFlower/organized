describe "when organized:toggleTodo is used", ->
  beforeEach ->
    console.log("-".repeat(40))
    waitsForPromise ->
      atom.workspace.open('/test.org')

    waitsForPromise ->
      atom.packages.activatePackage('organized')

    atom.config.set("organized.trackCloseTimeOfTodos", false)

  parameterized = (cursorPos, before, after) ->
    describe "string", ->

      it "should be transformed", ->
        console.log("Testing #{before} becomes #{after}")
        editor = atom.workspace.getActiveTextEditor()
        editor.setText(before)
        editor.setCursorBufferPosition(cursorPos)
        textEditorView = atom.views.getView(editor)
        atom.commands.dispatch(textEditorView, "organized:toggleTodo")
        newLine = editor.getText(after)
        expect(newLine).toBe(after)


  parameterized([0, 0], "* One",              "* [TODO] One")
  parameterized([0, 0], "* [TODO] One",       "* [DONE] One")
  parameterized([0, 0], "* [DONE] One",  "* One")
  parameterized([0, 0], "- One",              "- [TODO] One")
  parameterized([0, 0], "- [TODO] One",       "- [DONE] One")
  parameterized([0, 0], "- [DONE] One",  "- One")
  parameterized([0, 0], "+ One",              "+ [TODO] One")
  parameterized([0, 0], "+ [TODO] One",       "+ [DONE] One")
  parameterized([0, 0], "+ [DONE] One",  "+ One")
  parameterized([0, 0], "1. One",             "1. [TODO] One")
  parameterized([0, 0], "1. [TODO] One",      "1. [DONE] One")
  parameterized([0, 0], "1. [DONE] One", "1. One")
  parameterized([1, 0], "* One\n  * Two",             "* One\n  * [TODO] Two")
  parameterized([1, 0], "* One\n  * [TODO] Two",      "* One\n  * [DONE] Two")
  parameterized([1, 0], "* One\n  * [DONE] Two", "* One\n  * Two")
  parameterized([1, 0], "- One\n  - Two",             "- One\n  - [TODO] Two")
  parameterized([1, 0], "- One\n  - [TODO] Two",      "- One\n  - [DONE] Two")
  parameterized([1, 0], "- One\n  - [DONE] Two", "- One\n  - Two")
  parameterized([1, 0], "+ One\n  + Two",             "+ One\n  + [TODO] Two")
  parameterized([1, 0], "+ One\n  + [TODO] Two",      "+ One\n  + [DONE] Two")
  parameterized([1, 0], "+ One\n  + [DONE] Two", "+ One\n  + Two")
  parameterized([1, 0], "* One\n\t* Two",             "* One\n\t* [TODO] Two")
  parameterized([1, 0], "* One\n\t* [TODO] Two",      "* One\n\t* [DONE] Two")
  parameterized([1, 0], "* One\n\t* [DONE] Two", "* One\n\t* Two")
  parameterized([0, 0], '# Heading', '# Heading')
  parameterized([0, 0], 'abc', 'abc')


  # it "'* One' becomes '* [TODO] One'", ->
  #   editor = atom.workspace.getActiveTextEditor()
  #   editor.setText("* One\n")
  #   textEditorView = atom.views.getView(editor)
  #   atom.commands.dispatch(textEditorView, "organized:toggleTodo")
  #   newLine = editor.lineTextForBufferRow(0)
  #   expect(newLine).toBe("* [TODO] One")
  #
  # it "'* [TODO] One' becomes '* [COMPLETED] One'", ->
  #   editor = atom.workspace.getActiveTextEditor()
  #   editor.setText("* [TODO] One\n")
  #   textEditorView = atom.views.getView(editor)
  #   atom.commands.dispatch(textEditorView, "organized:toggleTodo")
  #   newLine = editor.lineTextForBufferRow(0)
  #   expect(newLine).toBe("* [COMPLETED] One")
  #
  # it "'* [COMPLETED] One' becomes '* One'", ->
  #   editor = atom.workspace.getActiveTextEditor()
  #   editor.setText("* [COMPLETED] One\n")
  #   textEditorView = atom.views.getView(editor)
  #   atom.commands.dispatch(textEditorView, "organized:toggleTodo")
  #   newLine = editor.lineTextForBufferRow(0)
  #   expect(newLine).toBe("* One")
