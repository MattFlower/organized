describe "when todo priories are used", ->
  beforeEach ->
    console.log("-".repeat(40))
    waitsForPromise ->
      atom.workspace.open('/test.org')

    waitsForPromise ->
      atom.packages.activatePackage('organized')

  increasePriority = (cursorPos, before, after) ->
    describe before + " --> " + after, ->
      it "increasePriority", ->
        editor = atom.workspace.getActiveTextEditor()
        editor.setText(before)
        editor.setCursorBufferPosition(cursorPos)
        textEditorView = atom.views.getView(editor)
        atom.commands.dispatch(textEditorView, "organized:increasePriority")
        newLine = editor.getText(after)
        expect(newLine).toBe(after)

  decreasePriority = (cursorPos, before, after) ->
    describe before + " --> " + after, ->
      it "decreasePriority", ->
        editor = atom.workspace.getActiveTextEditor()
        editor.setText(before)
        editor.setCursorBufferPosition(cursorPos)
        textEditorView = atom.views.getView(editor)
        atom.commands.dispatch(textEditorView, "organized:decreasePriority")
        newLine = editor.getText(after)
        expect(newLine).toBe(after)

  increasePriority([0,0], "* One",      "* [#A] One")
  increasePriority([0,0], "* [#A] One", "* One")
  increasePriority([0,0], "* [#B] One", "* [#A] One")
  increasePriority([0,0], "* [#C] One", "* [#B] One")
  increasePriority([0,0], "* [#D] One", "* [#C] One")
  increasePriority([0,0], "* [#E] One", "* [#D] One")

  increasePriority([0,0], "* [TODO] One",      "* [TODO] [#A] One")
  increasePriority([0,0], "* [TODO] [#A] One", "* [TODO] One")
  increasePriority([0,0], "* [TODO] [#B] One", "* [TODO] [#A] One")
  increasePriority([0,0], "* [TODO] [#C] One", "* [TODO] [#B] One")
  increasePriority([0,0], "* [TODO] [#D] One", "* [TODO] [#C] One")
  increasePriority([0,0], "* [TODO] [#E] One", "* [TODO] [#D] One")

  increasePriority([0,0], "* TODO One",      "* TODO [#A] One")
  increasePriority([0,0], "* TODO [#A] One", "* TODO One")
  increasePriority([0,0], "* TODO [#B] One", "* TODO [#A] One")
  increasePriority([0,0], "* TODO [#C] One", "* TODO [#B] One")
  increasePriority([0,0], "* TODO [#D] One", "* TODO [#C] One")
  increasePriority([0,0], "* TODO [#E] One", "* TODO [#D] One")

  increasePriority([0,0], "* [DONE] One",      "* [DONE] [#A] One")
  increasePriority([0,0], "* [DONE] [#A] One", "* [DONE] One")
  increasePriority([0,0], "* [DONE] [#B] One", "* [DONE] [#A] One")
  increasePriority([0,0], "* [DONE] [#C] One", "* [DONE] [#B] One")
  increasePriority([0,0], "* [DONE] [#D] One", "* [DONE] [#C] One")
  increasePriority([0,0], "* [DONE] [#E] One", "* [DONE] [#D] One")

  increasePriority([0,0], "* DONE One",      "* DONE [#A] One")
  increasePriority([0,0], "* DONE [#A] One", "* DONE One")
  increasePriority([0,0], "* DONE [#B] One", "* DONE [#A] One")
  increasePriority([0,0], "* DONE [#C] One", "* DONE [#B] One")
  increasePriority([0,0], "* DONE [#D] One", "* DONE [#C] One")
  increasePriority([0,0], "* DONE [#E] One", "* DONE [#D] One")

  increasePriority([0,0], "* [COMPLETED] One",      "* [COMPLETED] [#A] One")
  increasePriority([0,0], "* [COMPLETED] [#A] One", "* [COMPLETED] One")
  increasePriority([0,0], "* [COMPLETED] [#B] One", "* [COMPLETED] [#A] One")
  increasePriority([0,0], "* [COMPLETED] [#C] One", "* [COMPLETED] [#B] One")
  increasePriority([0,0], "* [COMPLETED] [#D] One", "* [COMPLETED] [#C] One")
  increasePriority([0,0], "* [COMPLETED] [#E] One", "* [COMPLETED] [#D] One")

  increasePriority([0,0], "* COMPLETED One",      "* COMPLETED [#A] One")
  increasePriority([0,0], "* COMPLETED [#A] One", "* COMPLETED One")
  increasePriority([0,0], "* COMPLETED [#B] One", "* COMPLETED [#A] One")
  increasePriority([0,0], "* COMPLETED [#C] One", "* COMPLETED [#B] One")
  increasePriority([0,0], "* COMPLETED [#D] One", "* COMPLETED [#C] One")
  increasePriority([0,0], "* COMPLETED [#E] One", "* COMPLETED [#D] One")

  decreasePriority([0,0], "* One",      "* [#E] One")
  decreasePriority([0,0], "* [#E] One", "* One")
  decreasePriority([0,0], "* [#A] One", "* [#B] One")
  decreasePriority([0,0], "* [#B] One", "* [#C] One")
  decreasePriority([0,0], "* [#C] One", "* [#D] One")
  decreasePriority([0,0], "* [#D] One", "* [#E] One")

  decreasePriority([0,0], "* [TODO] One",      "* [TODO] [#E] One")
  decreasePriority([0,0], "* [TODO] [#E] One", "* [TODO] One")
  decreasePriority([0,0], "* [TODO] [#A] One", "* [TODO] [#B] One")
  decreasePriority([0,0], "* [TODO] [#B] One", "* [TODO] [#C] One")
  decreasePriority([0,0], "* [TODO] [#C] One", "* [TODO] [#D] One")
  decreasePriority([0,0], "* [TODO] [#D] One", "* [TODO] [#E] One")
