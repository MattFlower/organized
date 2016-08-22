describe "Pressing enter creates a new star", ->

  beforeEach ->
    console.log("-".repeat(40))
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
  # parameterized([0,6], [1,3], "1. One", "1. One\n2. ")

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

  it "can roll over to 10 if the previous star was a 9.", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("9. Hi")
    editor.setCursorBufferPosition([0, 5])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:newStarLine")
    expect(editor.getText()).toBe("9. Hi\n10. ")
    newCursorPosition = editor.getCursorBufferPosition()
    expect(newCursorPosition.row).toBe(1)
    expect(newCursorPosition.column).toBe(4)

  it "can roll over to 11 if the previous star was a 10.", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("10. Hi")
    editor.setCursorBufferPosition([0, 6])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:newStarLine")
    expect(editor.getText()).toBe("10. Hi\n11. ")
    newCursorPosition = editor.getCursorBufferPosition()
    expect(newCursorPosition.row).toBe(1)
    expect(newCursorPosition.column).toBe(4)

  it "can roll over to 100 if the previous star was a 99.", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("99. Hi")
    editor.setCursorBufferPosition([0, 6])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:newStarLine")
    expect(editor.getText()).toBe("99. Hi\n100. ")
    newCursorPosition = editor.getCursorBufferPosition()
    expect(newCursorPosition.row).toBe(1)
    expect(newCursorPosition.column).toBe(5)

  it "can re-number numbered lines to make space", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("1. A\n2. C\n3. D")
    editor.setCursorBufferPosition([0, 4])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:newStarLine")
    expect(editor.getText()).toBe("1. A\n2. \n3. C\n4. D")
    newCursorPosition = editor.getCursorBufferPosition()
    expect(newCursorPosition.row).toBe(1)
    expect(newCursorPosition.column).toBe(3)
