Table = require '../lib/table'

describe "When calling findRowColumns", ->
  beforeEach ->
    console.log("-".repeat(40))
    waitsForPromise ->
      atom.workspace.open('test.org')
    waitsForPromise ->
      atom.packages.activatePackage("organized")

  it "can find a single column table", ->
    editor = atom.workspace.getActiveTextEditor()
    table = new Table(editor, editor.getCursorBufferPosition())
    editor.setText("|a|")
    columns = table.findRowColumns(0)

    expect(columns).toEqual([0,2])

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

describe "when findColumn is called", ->
  beforeEach ->
    console.log("-".repeat(40))
    waitsForPromise ->
      atom.workspace.open('test.org')
    # waitsForPromise ->
    #   atom.packages.activatePackage("organized")

  it "can find the correct position if there is 1 column", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("|a|")
    table = new Table(editor)
    editor.setCursorBufferPosition([0,1])
    expect(table.currentColumnIndex()).toBe(0)
    editor.setCursorBufferPosition([0,2])
    expect(table.currentColumnIndex()).toBe(0)
    editor.setCursorBufferPosition([0,3])
    expect(table.currentColumnIndex()).toBe(-1)

  it "can find the correct position if there are 2 columns", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("|a|b|")
    table = new Table(editor)
    editor.setCursorBufferPosition([0,1])
    expect(table.currentColumnIndex()).toBe(0)
    editor.setCursorBufferPosition([0,2])
    expect(table.currentColumnIndex()).toBe(0)
    editor.setCursorBufferPosition([0,3])
    expect(table.currentColumnIndex()).toBe(1)
    editor.setCursorBufferPosition([0,4])
    expect(table.currentColumnIndex()).toBe(1)

  it "can find the correct position if there are 3 columns", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("|a|b|c|")
    table = new Table(editor)
    editor.setCursorBufferPosition([0,1])
    expect(table.currentColumnIndex()).toBe(0)
    editor.setCursorBufferPosition([0,2])
    expect(table.currentColumnIndex()).toBe(0)
    editor.setCursorBufferPosition([0,3])
    expect(table.currentColumnIndex()).toBe(1)
    editor.setCursorBufferPosition([0,4])
    expect(table.currentColumnIndex()).toBe(1)
    editor.setCursorBufferPosition([0,5])
    expect(table.currentColumnIndex()).toBe(2)
    editor.setCursorBufferPosition([0,6])
    expect(table.currentColumnIndex()).toBe(2)
