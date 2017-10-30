Table = require '../lib/table'

describe "the table class", ->
  beforeEach ->
    console.log("-".repeat(40))
    waitsForPromise ->
      atom.workspace.open('/test.org')
    waitsForPromise ->
      atom.packages.activatePackage("organized")

  it "finds the first row of a table with border when a table is the whole buffer", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("\n"+
                   " +---+\n"+
                   " | A |\n"+
                   " +---+\n"+
                   "\n")
    editor.setCursorBufferPosition([2, 1])
    table = new Table(editor, editor.getCursorBufferPosition())
    expect(table.found).toBe(true)
    expect(table.firstRow).toBe(1)
    expect(table.lastRow).toBe(3)

  it "finds the first row of a multi-column table with border when a table is the whole buffer", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("\n"+
                   " +---+---+\n"+
                   " | A | B |\n"+
                   " +---+---+\n"+
                   "\n")
    editor.setCursorBufferPosition([2, 1])
    table = new Table(editor, editor.getCursorBufferPosition())
    expect(table.found).toBe(true)
    expect(table.firstRow).toBe(1)
    expect(table.lastRow).toBe(3)

  it "finds the first row of a border-less table with border when a table is the whole buffer", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("\n"+
                   " | A | B |\n"+
                   "\n")
    editor.setCursorBufferPosition([1, 1])
    table = new Table(editor, editor.getCursorBufferPosition())
    expect(table.found).toBe(true)
    expect(table.firstRow).toBe(1)
    expect(table.lastRow).toBe(1)

  it "knows the number of columns in a one-column table border", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText(" +---+\n"+
                   " | A |\n"+
                   " +---+\n")

    editor.setCursorBufferPosition([0, 1])
    table = new Table(editor, editor.getCursorBufferPosition())

    info = table.rowInfo([0, 1])
    expect(info.found).toBe(true)
    expect(info.colCount).toBe(1)

    info = table.rowInfo([1, 1])
    expect(info.found).toBe(true)
    expect(info.colCount).toBe(1)

    info = table.rowInfo([2, 1])
    expect(info.found).toBe(true)
    expect(info.colCount).toBe(1)

  it "knows the number of columns in a two-column table border", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText(" +---+---+\n"+
                   " | A | B |\n"+
                   " +---+---+\n")

    editor.setCursorBufferPosition([0, 1])
    table = new Table(editor, editor.getCursorBufferPosition())

    info = table.rowInfo([0, 1])
    expect(info.found).toBe(true)
    expect(info.colCount).toBe(2)

    info = table.rowInfo([1, 1])
    expect(info.found).toBe(true)
    expect(info.colCount).toBe(2)

    info = table.rowInfo([2, 1])
    expect(info.found).toBe(true)
    expect(info.colCount).toBe(2)


describe "When using grammar to parse a table row", ->
  beforeEach ->
    console.log("-".repeat(40))
    waitsForPromise ->
      atom.workspace.open('/test.org')
    waitsForPromise ->
      atom.packages.activatePackage("organized")

  it "finds the borders and rows correctly on a table row with a single column", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("|a|")
    editor.setCursorBufferPosition([0, 0])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([0, 1])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("row.table.organized")
    editor.setCursorBufferPosition([0, 2])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")

  it "finds the borders and rows correctly on a table row with two columns", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("|a|b|")
    editor.setCursorBufferPosition([0, 0])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([0, 1])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("row.table.organized")
    editor.setCursorBufferPosition([0, 2])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([0, 3])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("row.table.organized")
    editor.setCursorBufferPosition([0, 4])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")

  it "finds the borders and rows correctly on a table row with three columns", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("|a|b|c|")
    editor.setCursorBufferPosition([0, 0])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([0, 1])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("row.table.organized")
    editor.setCursorBufferPosition([0, 2])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([0, 3])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("row.table.organized")
    editor.setCursorBufferPosition([0, 4])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([0, 5])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("row.table.organized")
    editor.setCursorBufferPosition([0, 6])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")

  it "finds border and row content correctly on a table with borders", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("+-+-+-+\n|a|b|c|\n+-+-+-+")
    editor.setCursorBufferPosition([0, 0])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([0, 1])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([0, 2])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([0, 3])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([0, 4])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([0, 5])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([0, 6])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")

    editor.setCursorBufferPosition([1, 0])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([1, 1])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("row.table.organized")
    editor.setCursorBufferPosition([1, 2])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([1, 3])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("row.table.organized")
    editor.setCursorBufferPosition([1, 4])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([1, 5])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("row.table.organized")
    editor.setCursorBufferPosition([1, 6])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")

    editor.setCursorBufferPosition([2, 0])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([2, 1])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([2, 2])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([2, 3])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([2, 4])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([2, 5])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
    editor.setCursorBufferPosition([2, 6])
    expect(editor.getLastCursor().getScopeDescriptor().getScopesArray()).toContain("border.table.organized")
