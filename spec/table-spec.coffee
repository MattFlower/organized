Table = require '../lib/table'

describe "When using grammar to parse a table row", ->
  beforeEach ->
    console.log("-".repeat(40))
    waitsForPromise ->
      atom.workspace.open('test.org')
    waitsForPromise ->
      atom.packages.activatePackage("organized")

  it "finds the borders correctly on a table row with a single column", ->
    editor = atom.workspace.getActiveTextEditor()
    table = new Table(editor, editor.getCursorBufferPosition())
    editor.setText("|a|")
    editor.setCursorBufferPosition([0, 0])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([0, 2])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")

  it "finds row content correctly on a table row with a single column", ->
    editor = atom.workspace.getActiveTextEditor()
    table = new Table(editor, editor.getCursorBufferPosition())
    editor.setText("|a|")
    editor.setCursorBufferPosition([0, 1])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("row.table.organized")

  it "finds the borders correctly on a table row with two columns", ->
    editor = atom.workspace.getActiveTextEditor()
    table = new Table(editor, editor.getCursorBufferPosition())
    editor.setText("|a|b|")
    editor.setCursorBufferPosition([0, 0])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([0, 2])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([0, 4])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")

  it "finds row content correctly on a table row with two columns", ->
    editor = atom.workspace.getActiveTextEditor()
    table = new Table(editor, editor.getCursorBufferPosition())
    editor.setText("|a|b|")
    editor.setCursorBufferPosition([0, 1])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("row.table.organized")
    editor.setCursorBufferPosition([0, 3])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("row.table.organized")

  it "finds the borders correctly on a table row with three columns", ->
    editor = atom.workspace.getActiveTextEditor()
    table = new Table(editor, editor.getCursorBufferPosition())
    editor.setText("|a|b|c|")
    editor.setCursorBufferPosition([0, 0])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([0, 2])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([0, 4])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([0, 6])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")

  it "finds row content correctly on a table row with three columns", ->
    editor = atom.workspace.getActiveTextEditor()
    table = new Table(editor, editor.getCursorBufferPosition())
    editor.setText("|a|b|c|")
    editor.setCursorBufferPosition([0, 1])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("row.table.organized")
    editor.setCursorBufferPosition([0, 3])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("row.table.organized")
    editor.setCursorBufferPosition([0, 5])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("row.table.organized")
