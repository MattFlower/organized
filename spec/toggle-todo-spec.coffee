describe "when organized:toggleTodo is used", ->
  beforeEach ->
    waitsForPromise ->
      atom.workspace.open('test.org')

    waitsForPromise ->
      atom.packages.activatePackage('organized')

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


  parameterized([0, 0], "* One",             "* [TODO] One")
  parameterized([0, 0], "* [TODO] One",      "* [COMPLETED] One")
  parameterized([0, 0], "* [COMPLETED] One", "* One")
  parameterized([0, 0], "- One",             "- [TODO] One")
  parameterized([0, 0], "- [TODO] One",      "- [COMPLETED] One")
  parameterized([0, 0], "- [COMPLETED] One", "- One")
  parameterized([0, 0], "+ One",             "+ [TODO] One")
  parameterized([0, 0], "+ [TODO] One",      "+ [COMPLETED] One")
  parameterized([0, 0], "+ [COMPLETED] One", "+ One")
  parameterized([1, 0], "* One\n  * Two",             "* One\n  * [TODO] Two")
  parameterized([1, 0], "* One\n  * [TODO] Two",      "* One\n  * [COMPLETED] Two")
  parameterized([1, 0], "* One\n  * [COMPLETED] Two", "* One\n  * Two")
  parameterized([1, 0], "- One\n  - Two",             "- One\n  - [TODO] Two")
  parameterized([1, 0], "- One\n  - [TODO] Two",      "- One\n  - [COMPLETED] Two")
  parameterized([1, 0], "- One\n  - [COMPLETED] Two", "- One\n  - Two")
  parameterized([1, 0], "+ One\n  + Two",             "+ One\n  + [TODO] Two")
  parameterized([1, 0], "+ One\n  + [TODO] Two",      "+ One\n  + [COMPLETED] Two")
  parameterized([1, 0], "+ One\n  + [COMPLETED] Two", "+ One\n  + Two")
  parameterized([1, 0], "* One\n\t* Two",             "* One\n\t* [TODO] Two")
  parameterized([1, 0], "* One\n\t* [TODO] Two",      "* One\n\t* [COMPLETED] Two")
  parameterized([1, 0], "* One\n\t* [COMPLETED] Two", "* One\n\t* Two")
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
