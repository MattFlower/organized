describe "Pressing enter creates a new star", ->

  beforeEach ->
    waitsForPromise ->
      atom.workspace.open('test.org')

    waitsForPromise ->
      atom.packages.activatePackage('organized')

  parameterized = (cursorPos, finalCursorPos, before, after, newLevelStyle='whitespace') ->
    describe "organized:newStarLine", ->

      it "should create a new star", ->
        console.log("Testing\n#{before}\n<<becomes>>\n#{after}")
        atom.config.set('organized.levelStyle', newLevelStyle)
        editor = atom.workspace.getActiveTextEditor()
        editor.setText(before)
        editor.setCursorBufferPosition(cursorPos)
        textEditorView = atom.views.getView(editor)
        atom.commands.dispatch(textEditorView, "organized:newStarLine")
        newLine = editor.getText()
        expect(newLine).toBe(after)
        newCursorPosition = editor.getCursorBufferPosition()
        expect(newCursorPosition.row).toBe(finalCursorPos[0])
        expect(newCursorPosition.column).toBe(finalCursorPos[1])

  # Single level, multiple styles
  parameterized([0,5], [1,2], "* One", "* One\n* ")
  parameterized([0,5], [1,2], "- One", "- One\n- ")
  parameterized([0,5], [1,2], "+ One", "+ One\n+ ")

  # Second level, indented with spaces multiple styles
  parameterized([1,7], [2,4], "* One\n  * Two", "* One\n  * Two\n  * ")
  parameterized([1,7], [2,4], "- One\n  - Two", "- One\n  - Two\n  - ")
  parameterized([1,7], [2,4], "+ One\n  + Two", "+ One\n  + Two\n  + ")

  # Second level, indented with tabs, multiple styles
  parameterized([1,7], [2,3], "* One\n\t* Two", "* One\n\t* Two\n\t* ", 'tabs')
  parameterized([1,7], [2,3], "- One\n\t- Two", "- One\n\t- Two\n\t- ", 'tabs')
  parameterized([1,7], [2,3], "+ One\n\t+ Two", "+ One\n\t+ Two\n\t+ ", 'tabs')

  # Second level, indented with stacking, multiple styles
  parameterized([1,7], [2,3], "* One\n** Two", "* One\n** Two\n** ", 'stacked')
  parameterized([1,7], [2,3], "- One\n-- Two", "- One\n-- Two\n-- ", 'stacked')
  parameterized([1,7], [2,3], "+ One\n++ Two", "+ One\n++ Two\n++ ", 'stacked')

  describe "organized:newStarLine when autoCreateStarsOnEnter disabled", ->
    it "should not create a new star", ->
      atom.config.set('organized.autoCreateStarsOnEnter', false)
      editor = atom.workspace.getActiveTextEditor()
      editor.setText("* One")
      editor.setCursorBufferPosition([0, 5])
      textEditorView = atom.views.getView(editor)
      atom.commands.dispatch(textEditorView, "organized:newStarLine")
      newLine = editor.getText()
      expect(newLine).toBe("* One\n")
      newCursorPosition = editor.getCursorBufferPosition()
      expect(newCursorPosition.row).toBe(1)
      expect(newCursorPosition.column).toBe(0)
