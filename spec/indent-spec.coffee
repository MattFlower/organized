describe "organized:indent", ->
  beforeEach ->
    console.log("-".repeat(40))

    waitsForPromise ->
      atom.workspace.open('test.org')

    waitsForPromise ->
      atom.packages.activatePackage('organized')

  it "'* One\\n|* Two' becomes '* One\\n▢▢|* Two'", ->
    atom.config.set("organized.levelStyle", "whitespace")
    editor = atom.workspace.getActiveTextEditor()
    editor.setSoftTabs(true)
    editor.setText("* One\n* Two")
    editor.setCursorBufferPosition([1, 0])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:indent")
    newLine = editor.lineTextForBufferRow(1)
    expect(newLine).toBe("  * Two")

  it "'* One\\n|* Two' becomes '* One\\n▢▢*| Two'", ->
    atom.config.set("organized.levelStyle", "whitespace")
    editor = atom.workspace.getActiveTextEditor()
    editor.setSoftTabs(true)
    editor.setText("* One\n* Two")
    editor.setCursorBufferPosition([1, 1])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:indent")
    newLine = editor.lineTextForBufferRow(1)
    expect(newLine).toBe("  * Two")

  it "'* One\\n|* Two' becomes '* One\\n[tab]|* Two'", ->
    atom.config.set("organized.levelStyle", "whitespace")
    editor = atom.workspace.getActiveTextEditor()
    editor.softTabs = false
    editor.setText("* One\n* Two")
    editor.setCursorBufferPosition([1, 0])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:indent")
    newLine = editor.lineTextForBufferRow(1)
    expect(newLine).toBe("\t* Two")

  it "'* One\\n|* Two' becomes '* One\\n|** Two'", ->
    atom.config.set("organized.levelStyle", "stacked")
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* One\n* Two")
    editor.setCursorBufferPosition([1, 0])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:indent")
    newLine = editor.lineTextForBufferRow(1)
    expect(newLine).toBe("** Two")

  it "works with a live problem I found", ->
    atom.config.set("organized.levelStyle", "whitespace")
    editor = atom.workspace.getActiveTextEditor()
    editor.setSoftTabs(true)
    editor.setText("- A\n- \n\n* B")
    editor.setCursorBufferPosition([1, 1])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:indent")
    expect(editor.getText()).toBe("- A\n  - \n\n* B")

  it "should add tabs if the default indent type is tabs", ->
    atom.config.set('organized.levelStyle', 'whitespace')
    editor = atom.workspace.getActiveTextEditor()
    editor.softTabs = false
    editor.setText("* One\n")
    editor.setCursorBufferPosition([0, 1])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:indent")
    expect(editor.getText()).toBe("\t* One\n")

  it "should add an additional star if the indent type is stacked", ->
    atom.config.set('organized.levelStyle', 'stacked')
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* One\n")
    editor.setCursorBufferPosition([0, 1])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:indent")
    expect(editor.getText()).toBe("** One\n")

  it "should add spaces if the indent type is spaces", ->
    atom.config.set('organized.levelStyle', 'whitespace')
    editor = atom.workspace.getActiveTextEditor()
    editor.setSoftTabs(true)
    editor.setText("* One\n")
    editor.setCursorBufferPosition([0, 1])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:indent")
    expect(editor.getText()).toBe("  * One\n")

  it "should obey the indentSpaces setting when indentType is spaces", ->
    atom.config.set('organized.levelStyle', 'whitespace')
    atom.config.set('editor.tabLength', 5)
    editor = atom.workspace.getActiveTextEditor()
    editor.setSoftTabs(true)
    editor.setText("* One\n")
    editor.setCursorBufferPosition([0, 1])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:indent")
    expect(editor.getText()).toBe("     * One\n")

  it "should try to obey the levelStyle on the line, even if it disagrees with the default style", ->
    atom.config.set('organized.levelStyle', 'whitespace')
    editor = atom.workspace.getActiveTextEditor()
    editor.setSoftTabs(true)
    editor.setText("** Two\n")
    editor.setCursorBufferPosition([0, 2])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:indent")
    expect(editor.getText()).toBe("*** Two\n")

#
# describe "when a line with one indent level (one tab) is indented", ->
#   it "should add another indent level (one more tab)", ->
#     expect("").toEqual("")
#
# describe "when a line with one indent level (one star) is indented", ->
#   it "should add another indent level (one more star)", ->
#     expect("").toEqual("")
#
# describe "when a line with two indent levels (six spaces) is indented", ->
#   it "should add another indent level (three more spaces)", ->
#     expect("").toEqual("")
