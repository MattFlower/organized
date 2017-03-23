describe "when the schedule command is used", ->
  beforeEach ->
    console.log("-".repeat(40))
    waitsForPromise ->
      atom.workspace.open('test.org')

    waitsForPromise ->
      atom.packages.activatePackage('organized')

  _getCurrentDate = () ->
    d = new Date()
    df = new Intl.DateTimeFormat('en-US', {weekday: 'short'})
    dow = df.format(d)

    year = ("0000" + d.getFullYear()).substr(-4, 4)
    month = ("00" + (d.getMonth() + 1)).substr(-2, 2)
    date = ("00" + d.getDate()).substr(-2, 2)
    isoDate = "" + year + "-" + month + "-" + date

    return "<#{isoDate} #{dow}>"

  parameterized = (cursorPos, before, after) ->
    describe "string", ->

      it "should be transformed", ->
        console.log("Testing #{before} becomes #{after}")
        editor = atom.workspace.getActiveTextEditor()
        editor.setText(before)
        editor.setCursorBufferPosition(cursorPos)
        textEditorView = atom.views.getView(editor)
        atom.commands.dispatch(textEditorView, "organized:scheduleItem")
        newLine = editor.getText()


        after = after.replace("{date}", _getCurrentDate())
        expect(newLine).toBe(after)

  parameterized([0,0], "* One", "* One\n  SCHEDULED: {date}")
  parameterized([0,0], "* One\n* Two", "* One\n  SCHEDULED: {date}\n* Two")
  parameterized([0,0], "* One\n  * Two", "* One\n  SCHEDULED: {date}\n  * Two")
