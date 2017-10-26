describe "organized:cycleVisibility", ->
  beforeEach ->
    console.log("-".repeat(40))

    waitsForPromise ->
      atom.workspace.open('test.org')

    waitsForPromise ->
      atom.packages.activatePackage('organized')

  it "Fully folded to top level only with indented stars", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* A\n  * A.1\n    * A.1.1\n  * A.2\n  * A.3\n")
    editor.setCursorBufferPosition([0, 0])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, 'organized:cycleVisibility')
    expect(editor.isFoldedAtBufferRow(0)).toBe(true)
    expect(editor.isFoldedAtBufferRow(1)).toBe(true)
    expect(editor.isFoldedAtBufferRow(2)).toBe(true)
    expect(editor.isFoldedAtBufferRow(3)).toBe(true)
    expect(editor.isFoldedAtBufferRow(4)).toBe(true)

  it "Fully folded to top level only with stacked stars", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* A\n** A.1\n*** A.1.1\n** A.2\n** A.3\n")
    editor.setCursorBufferPosition([0, 0])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, 'organized:cycleVisibility')
    expect(editor.isFoldedAtBufferRow(0)).toBe(true)
    expect(editor.isFoldedAtBufferRow(1)).toBe(true)
    expect(editor.isFoldedAtBufferRow(2)).toBe(true)
    expect(editor.isFoldedAtBufferRow(3)).toBe(true)
    expect(editor.isFoldedAtBufferRow(4)).toBe(true)

  it "Folds to first levels if it was globally folded with indented stars", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* A\n  * A.1\n    * A.1.1\n  * A.2\n  * A.3\n")
    editor.setCursorBufferPosition([0, 0])
    editor.foldBufferRange([[0, Infinity], [4, Infinity]])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, 'organized:cycleVisibility')
    expect(editor.isFoldedAtBufferRow(0)).toBe(false)
    expect(editor.isFoldedAtBufferRow(1)).toBe(true)
    expect(editor.isFoldedAtBufferRow(2)).toBe(true)
    expect(editor.isFoldedAtBufferRow(3)).toBe(false)
    expect(editor.isFoldedAtBufferRow(4)).toBe(false)

  it "Folds to first levels if it was globally folded with stacked stars", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* A\n** A.1\n*** A.1.1\n** A.2\n** A.3\n")
    editor.setCursorBufferPosition([0, 0])
    editor.foldBufferRange([[0, Infinity], [4, Infinity]])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, 'organized:cycleVisibility')
    expect(editor.isFoldedAtBufferRow(0)).toBe(false)
    expect(editor.isFoldedAtBufferRow(1)).toBe(true)
    expect(editor.isFoldedAtBufferRow(2)).toBe(true)
    expect(editor.isFoldedAtBufferRow(3)).toBe(false)
    expect(editor.isFoldedAtBufferRow(4)).toBe(false)

  it "Fully unfolds if at first level with indented stars", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* A\n  * A.1\n    * A.1.1\n  * A.2\n  * A.3\n")
    editor.setCursorBufferPosition([0, 0])
    editor.foldBufferRange([[1, Infinity], [2, Infinity]])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, 'organized:cycleVisibility')

    expect(editor.isFoldedAtBufferRow(0)).toBe(false)
    expect(editor.isFoldedAtBufferRow(1)).toBe(false)
    expect(editor.isFoldedAtBufferRow(2)).toBe(false)
    expect(editor.isFoldedAtBufferRow(3)).toBe(false)
    expect(editor.isFoldedAtBufferRow(4)).toBe(false)

  it "Fully unfolds if at first level with stacked stars", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* A\n** A.1\n*** A.1.1\n** A.2\n** A.3\n")
    editor.setCursorBufferPosition([0, 0])
    editor.foldBufferRange([[1, Infinity], [2, Infinity]])
    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, 'organized:cycleVisibility')

    expect(editor.isFoldedAtBufferRow(0)).toBe(false)
    expect(editor.isFoldedAtBufferRow(1)).toBe(false)
    expect(editor.isFoldedAtBufferRow(2)).toBe(false)
    expect(editor.isFoldedAtBufferRow(3)).toBe(false)
    expect(editor.isFoldedAtBufferRow(4)).toBe(false)
