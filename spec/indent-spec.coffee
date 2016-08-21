describe "organized:indent", ->
  beforeEach ->
    waitsForPromise ->
      atom.workspace.open('test.org')

    waitsForPromise ->
      atom.packages.activatePackage('organized')

  it "'* One\\n|* Two' becomes '* One\\n▢▢|* Two'", ->
    atom.config.set("organized.levelStyle", "spaces")
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* One\n* Two")
    editor.setCursorBufferPosition([1, 0])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:indent")
    newLine = editor.lineTextForBufferRow(1)
    expect(newLine).toBe("  * Two")

  it "'* One\\n|* Two' becomes '* One\\n▢▢*| Two'", ->
    atom.config.set("organized.levelStyle", "spaces")
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* One\n* Two")
    editor.setCursorBufferPosition([1, 1])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:indent")
    newLine = editor.lineTextForBufferRow(1)
    expect(newLine).toBe("  * Two")

  it "'* One\\n|* Two' becomes '* One\\n[tab]|* Two'", ->
    atom.config.set("organized.levelStyle", "tabs")
    editor = atom.workspace.getActiveTextEditor()
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
    atom.config.set("organized.levelStyle", "spaces")
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("- A\n- \n\n* B")
    editor.setCursorBufferPosition([1, 1])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:indent")
    expect(editor.getText()).toBe("- A\n  - \n\n* B")



#   it "should add tabs if the default indent type is tabs", ->
#     expect("").toEqual("")
#
#   it "should add an additional star if the indent type is stars", ->
#     expect("").toEqual("")
#
# describe "when a line with one indent level (two spaces) is indented", ->
#   it "should add another indent level (two more spaces)", ->
#     expect("").toEqual("")
#
# describe "when a line with one indent level (three spaces) is indented", ->
#   it "should add another indent level (three more spaces)", ->
#     expect("").toEqual("")
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
