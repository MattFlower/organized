describe "Pressing ctrl-enter creates a new line indented to the text", ->

  beforeEach ->
    console.log("-".repeat(40))
    waitsForPromise ->
      atom.workspace.open('/test.org')

    waitsForPromise ->
      atom.packages.activatePackage('organized')

  parameterized = (title,cursorPos, finalCursorPos, before, after, newLevelStyle='whitespace') ->
    describe "organized:newLine", ->

      it "should indent properly for " + title, ->
        console.log("Testing\n#{before}\n<<becomes>>\n#{after}")
        atom.config.set("organized.levelStyle", if newLevelStyle is 'stacked' then 'stacked' else 'whitespace')
        editor = atom.workspace.getActiveTextEditor()
        editor.softTabs = if newLevelStyle is 'tabs' then false else true
        editor.setText(before)
        editor.setCursorBufferPosition(cursorPos)
        textEditorView = atom.views.getView(editor)
        atom.commands.dispatch(textEditorView, "organized:newLine")
        newLine = editor.getText()
        expect(newLine).toBe(after)
        newCursorPosition = editor.getCursorBufferPosition()
        expect(newCursorPosition.row).toBe(finalCursorPos[0])
        expect(newCursorPosition.column).toBe(finalCursorPos[1])

  # Single level, multiple styles
  parameterized("level 1 star",[0,5], [1,2], "* One", "* One\n  ")
  parameterized("level 1 line",[0,5], [1,2], "- One", "- One\n  ")
  parameterized("level 1 plus",[0,5], [1,2], "+ One", "+ One\n  ")

  parameterized("level 2 star",[1,7], [2,4], "* One\n  * Two", "* One\n  * Two\n    ")
  parameterized("level 2 line",[1,7], [2,4], "- One\n  - Two", "- One\n  - Two\n    ")
  parameterized("level 2 plus",[1,7], [2,4], "+ One\n  + Two", "+ One\n  + Two\n    ")

  # Same with tabs
  parameterized("level 1 star with tabs",[0,5], [1,2], "* One", "* One\n  ", 'tabs')
  parameterized("level 1 line with tabs",[0,5], [1,2], "- One", "- One\n  ", 'tabs')
  parameterized("level 1 plus with tabs",[0,5], [1,2], "+ One", "+ One\n  ", 'tabs')

  parameterized("level 2 star with tabs",[1,7], [2,3], "- One\n\t- Two", "- One\n\t- Two\n\t  ", 'tabs')
  parameterized("level 2 line with tabs",[1,7], [2,3], "+ One\n\t+ Two", "+ One\n\t+ Two\n\t  ", 'tabs')
  parameterized("level 2 plus with tabs",[1,7], [2,3], "* One\n\t* Two", "* One\n\t* Two\n\t  ", 'tabs')

  parameterized("Level 1 number", [0,6], [1,3], "1. One", "1. One\n   ")
  parameterized("Level 1 large number", [0,7], [1,4], "10. One", "10. One\n    ")

  parameterized("Level 2 stacked star", [0,6], [1,3], "** Two", "** Two\n   ")

  parameterized("Level 1 with TODO", [0,13], [1,2], "* [TODO] One", "* [TODO] One\n  ")
