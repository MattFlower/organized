describe "organized:unindent", ->
  beforeEach ->
    waitsForPromise ->
      atom.workspace.open('test.org')

    waitsForPromise ->
      atom.packages.activatePackage('organized')

  it "should remove two spaces if the default indent type is spaces", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* One\n  * Two")

    oldLine = editor.lineTextForBufferRow(1)
    editor.setCursorBufferPosition([1, 0])

    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:unindent")
    newLine = editor.lineTextForBufferRow(1)

    expect(atom.packages.isPackageActive('organized')).toBe(true)
    expect(newLine).toBe("* Two")

  it "should remove a tab if the default indent type is tabs", ->
    atom.config.set("organized.levelStyle", "tabs")
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* One\n\t* Two")

    oldLine = editor.lineTextForBufferRow(1)
    editor.setCursorBufferPosition([1, 0])

    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:unindent")
    newLine = editor.lineTextForBufferRow(1)

    expect(atom.packages.isPackageActive('organized')).toBe(true)
    expect(newLine).toBe("* Two")

  it "should remove a star if the default indent type is stacked", ->
    atom.config.set("organized.levelStyle", "stacked")
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* One\n** Two")

    oldLine = editor.lineTextForBufferRow(1)
    editor.setCursorBufferPosition([1, 0])

    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:unindent")
    newLine = editor.lineTextForBufferRow(1)

    expect(atom.packages.isPackageActive('organized')).toBe(true)
    expect(newLine).toBe("* Two")

  it "should remove a minus if the default indent type is stacked", ->
    atom.config.set("organized.levelStyle", "stacked")
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("- One\n-- Two")

    oldLine = editor.lineTextForBufferRow(1)
    editor.setCursorBufferPosition([1, 0])

    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:unindent")
    newLine = editor.lineTextForBufferRow(1)

    expect(atom.packages.isPackageActive('organized')).toBe(true)
    expect(newLine).toBe("- Two")

  it "should remove a plus if the default indent type is stacked", ->
    atom.config.set("organized.levelStyle", "stacked")
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("+ One\n++ Two")

    oldLine = editor.lineTextForBufferRow(1)
    editor.setCursorBufferPosition([1, 0])

    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:unindent")
    newLine = editor.lineTextForBufferRow(1)

    expect(atom.packages.isPackageActive('organized')).toBe(true)
    expect(newLine).toBe("+ Two")
