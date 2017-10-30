describe "when the schedule command is used", ->
  beforeEach ->
    console.log("-".repeat(40))
    waitsForPromise ->
      atom.workspace.open('/test.org')

    waitsForPromise ->
      atom.packages.activatePackage('organized')

  _getISO8601Date = (date) ->
    year = ("0000" + date.getFullYear()).substr(-4, 4)
    month = ("00" + (date.getMonth() + 1)).substr(-2, 2)
    date = ("00" + date.getDate()).substr(-2, 2)

    "" + year + "-" + month + "-" + date

  _getISO8601DateTime = (date) ->
    return _getISO8601Date(date) + "T" + _getISO8601Time(date)

  _getISO8601Time = (date) ->
    offset = date.getTimezoneOffset()
    if offset is 0
      offsetString = "Z"
    else
      negative = offset < 0;
      offsetHours = ("00" + Math.floor(offset/60)).substr(-2, 2)
      offsetMinutes = ("00" + (offset % 60)).substr(-2, 2)
      offsetString = if negative then "-" else "+"
      offsetString += offsetHours + ":" + offsetMinutes

    hours = ("00" + date.getHours()).substr(-2, 2)
    minutes = ("00" + date.getMinutes()).substr(-2, 2)
    seconds = ("00" + date.getSeconds()).substr(-2, 2)

    "" + hours + ":" + minutes + ":" + seconds + offsetString

  _getCurrentDate = () ->
    d = new Date()
    dt = _getISO8601DateTime(d)

    return "[#{dt}]"

  parameterized = (cursorPos, before, after) ->
    describe "string", ->

      it "should be transformed", ->
        console.log("Testing #{before} becomes #{after}")
        editor = atom.workspace.getActiveTextEditor()
        editor.setText(before)
        editor.setCursorBufferPosition(cursorPos)
        textEditorView = atom.views.getView(editor)
        atom.commands.dispatch(textEditorView, "organized:toggleTodo")
        newLine = editor.getText()


        after = after.replace("{date}", _getCurrentDate())
        expect(newLine).toBe(after)

  parameterized([0,0], "* [TODO] One\n  SCHEDULED: <2017-01-01>\n", "* [DONE] One\n  CLOSED: {date} SCHEDULED: <2017-01-01>\n")
  parameterized([0,0], "* [TODO] One\n", "* [DONE] One\n  CLOSED: {date}\n")
  parameterized([0,0], "- [TODO] One\n", "- [DONE] One\n  CLOSED: {date}\n")
  parameterized([0,0], "1. [TODO] One\n", "1. [DONE] One\n   CLOSED: {date}\n")
  parameterized([0,0], "1. [DONE] One\n   CLOSED: [2017-01-01T09:00:00]\n", "1. One\n")
  parameterized([0,0], "* [DONE] One\n   CLOSED: [2017-01-01T09:00:00]\n", "* One\n")
