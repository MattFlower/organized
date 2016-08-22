describe "Pressing ctrl-enter creates a new line indented to the text", ->

  beforeEach ->
    console.log("-".repeat(40))
    waitsForPromise ->
      atom.workspace.open('test.org')

    waitsForPromise ->
      atom.packages.activatePackage('organized')

  parameterized = (cursorPos, finalCursorPos, before, after, newLevelStyle='whitespace') ->
    describe "organized:newLine", ->

      it "should indent properly", ->
        console.log("Testing\n#{before}\n<<becomes>>\n#{after}")
        atom.config.set('organized.levelStyle', newLevelStyle)
        editor = atom.workspace.getActiveTextEditor()
        editor.setText(before)
        editor.setCursorBufferPosition(cursorPos)
        textEditorView = atom.views.getView(editor)
        atom.commands.dispatch(textEditorView, "organized:newLine")
        newLine = editor.getText()
        expect(newLine).toBe(after)
        newCursorPosition = editor.getCursorBufferPosition()
        expect(newCursorPosition.row).toBe(finalCursorPos[0])
        expect(newCursorPosition.column).toBe(finalCursorPos[1])

  # Single level, multiple styles
  parameterized([0,5], [1,2], "* One", "* One\n  ")
  parameterized([0,5], [1,2], "- One", "- One\n  ")
  parameterized([0,5], [1,2], "+ One", "+ One\n  ")

  parameterized([1,7], [2,4], "* One\n  * Two", "* One\n  * Two\n    ")
  parameterized([1,7], [2,4], "- One\n  - Two", "- One\n  - Two\n    ")
  parameterized([1,7], [2,4], "+ One\n  + Two", "+ One\n  + Two\n    ")

  # Same with tabs
  parameterized([0,5], [1,2], "* One", "* One\n  ", 'tabs')
  parameterized([0,5], [1,2], "- One", "- One\n  ", 'tabs')
  parameterized([0,5], [1,2], "+ One", "+ One\n  ", 'tabs')

  parameterized([1,7], [2,3], "* One\n\t* Two", "* One\n\t* Two\n\t  ", 'tabs')
  parameterized([1,7], [2,3], "- One\n\t- Two", "- One\n\t- Two\n\t  ", 'tabs')
  parameterized([1,7], [2,3], "+ One\n\t+ Two", "+ One\n\t+ Two\n\t  ", 'tabs')
