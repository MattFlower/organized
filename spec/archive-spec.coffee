moment = require 'moment'

describe "Running archiveSubtree", ->

  beforeEach ->
    console.log("-".repeat(40))
    waitsForPromise ->
      atom.workspace.open('test.org')

    waitsForPromise ->
      atom.packages.activatePackage('organized')

  it "should archive a single line with no subtree", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* One")
    editor.setCursorBufferPosition([0, 0])

    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:archiveToClipboard")
    archiveText = atom.clipboard.read()
    time = moment().format('YYYY-MM-DD ddd HH:mm')
    expectedText =
      "* One\n"+
      "  :PROPERTIES:\n"+
      "  :ARCHIVE_TIME: #{time}\n"+
      "  :ARCHIVE_FILE: /Applications/Atom.app/Contents/Resources/app.asar/spec/test.org\n"+
      "  :END:\n"

    expect(editor.getText()).toBe("")
    expect(archiveText).toBe(expectedText)

  it "should archive a subtree made with spaces", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText(
      "* One\n"+
      "  * Two\n")
    editor.setCursorBufferPosition([0, 0])

    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:archiveToClipboard")
    archiveText = atom.clipboard.read()
    time = moment().format('YYYY-MM-DD ddd HH:mm')
    expectedText =
      "* One\n"+
      "  :PROPERTIES:\n"+
      "  :ARCHIVE_TIME: #{time}\n"+
      "  :ARCHIVE_FILE: /Applications/Atom.app/Contents/Resources/app.asar/spec/test.org\n"+
      "  :END:\n"+
      "  * Two\n"

    expect(editor.getText()).toBe("")
    expect(archiveText).toBe(expectedText)

  it "should archive a subtree made with tabs", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText(
      "* One\n"+
      "\t* Two\n")
    editor.setCursorBufferPosition([0, 0])

    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:archiveToClipboard")
    archiveText = atom.clipboard.read()
    time = moment().format('YYYY-MM-DD ddd HH:mm')
    expectedText =
      "* One\n"+
      "\t:PROPERTIES:\n"+
      "\t:ARCHIVE_TIME: #{time}\n"+
      "\t:ARCHIVE_FILE: /Applications/Atom.app/Contents/Resources/app.asar/spec/test.org\n"+
      "\t:END:\n"+
      "\t* Two\n"

    expect(editor.getText()).toBe("")
    expect(archiveText).toBe(expectedText)

  it "should archive a subtree made with stacked stars", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText(
      "* One\n"+
      "** Two\n")
    editor.setCursorBufferPosition([0, 0])

    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:archiveToClipboard")
    archiveText = atom.clipboard.read()
    time = moment().format('YYYY-MM-DD ddd HH:mm')
    expectedText =
      "* One\n"+
      "  :PROPERTIES:\n"+
      "  :ARCHIVE_TIME: #{time}\n"+
      "  :ARCHIVE_FILE: /Applications/Atom.app/Contents/Resources/app.asar/spec/test.org\n"+
      "  :END:\n"+
      "** Two\n"

    expect(editor.getText()).toBe("")
    expect(archiveText).toBe(expectedText)

  it "should archive a subtree made with dashes", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText(
      "- One\n"+
      "  - Two\n")
    editor.setCursorBufferPosition([0, 0])

    textEditorView = atom.views.getView(editor)
    atom.commands.dispatch(textEditorView, "organized:archiveToClipboard")
    archiveText = atom.clipboard.read()
    time = moment().format('YYYY-MM-DD ddd HH:mm')
    expectedText =
      "- One\n"+
      "  :PROPERTIES:\n"+
      "  :ARCHIVE_TIME: #{time}\n"+
      "  :ARCHIVE_FILE: /Applications/Atom.app/Contents/Resources/app.asar/spec/test.org\n"+
      "  :END:\n"+
      "  - Two\n"

    expect(editor.getText()).toBe("")
    expect(archiveText).toBe(expectedText)
