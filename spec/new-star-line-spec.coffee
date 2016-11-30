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
  # parameterized([0,2], [1,0], "* One\n* ", "* One\n")
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

  # Continue to use stacked, even though your default type is spaces
  parameterized([1,6], [2,3], "* One\n** Two", "* One\n** Two\n** ", "spaces")

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

  it "can handle text after the cursor", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* Hello World")
    editor.setCursorBufferPosition([0, 8])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:newStarLine")
    expect(editor.getText()).toBe("* Hello \n* World")
    newCursorPosition = editor.getCursorBufferPosition()
    expect(newCursorPosition.row).toBe(1)
    expect(newCursorPosition.column).toBe(2)

  it "can handle all of the text after the cursor", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* Hello World")
    editor.setCursorBufferPosition([0, 0])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:newStarLine")
    expect(editor.getText()).toBe("\n* Hello World")
    newCursorPosition = editor.getCursorBufferPosition()
    expect(newCursorPosition.row).toBe(1)
    expect(newCursorPosition.column).toBe(0)

  it "wont create stars in the middle of a code block", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* One\n  ```python\n  print('hello')\n  ```")
    editor.setCursorBufferPosition([2, 16])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:newStarLine")
    #console.log("BABABABA: \n#{editor.getText()}")

    #Spacing here depends on whether you have the python plugin installed.
    expect(editor.getText()).toBe("* One\n  ```python\n  print('hello')\n  \n  ```")
    newCursorPosition = editor.getCursorBufferPosition()
    expect(newCursorPosition.row).toBe(3)
    # Not sure why, but this doesn't quite work the same here as in a live
    # editor.  In a live editor, I get indent, I don't here.  I suspect
    # it's due to auto-indent

  it "can handle numbered list if there isn't explicit outlining going on", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("Next: \n  1. One\n  2. Two")
    editor.setCursorBufferPosition([0, 0])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:newStarLine")

    expect(editor.getText()).toBe("\nNext: \n  1. One\n  2. Two")
    newCursorPosition = editor.getCursorBufferPosition()
    expect(newCursorPosition.row).toBe(1)
