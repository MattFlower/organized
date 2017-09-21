Star = require '../lib/star'

describe "When stars are parsed", ->
  beforeEach ->
    console.log("-".repeat(40))
    waitsForPromise ->
      atom.workspace.open('test.org')

    waitsForPromise ->
      atom.packages.activatePackage('organized')

  it "finds a numbered star at level 0 correctly", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("1. One")
    editor.setCursorBufferPosition([0, 0])

    star = new Star(0, 2)
    # console.log(star)
    expect(star.starType).toBe('numbers')
    expect(star.indentLevel).toBe(0)
    expect(star.indentType).toBe('none')
    expect(star.startRow).toBe(0)
    expect(star.endRow).toBe(0)
    expect(star.starCol).toBe(0)
    expect(star.nextNumber).toBe(2)
    expect(star.startTextCol).toBe(3)

  it "finds a numbered star at level 1 correctly", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("1. One\n  2. Two")
    editor.setCursorBufferPosition([1, 0])

    star = new Star(1, 2)
    # console.log(star)
    expect(star.starType).toBe('numbers')
    expect(star.indentLevel).toBe(1)
    expect(star.indentType).toBe('spaces')
    expect(star.startRow).toBe(1)
    expect(star.endRow).toBe(1)
    expect(star.starCol).toBe(2)
    expect(star.nextNumber).toBe(3)
    expect(star.startTextCol).toBe(5)

  it "finds a numbered star at level 2 correctly", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("1. One\n  2. Two\n    3. Three")
    editor.setCursorBufferPosition([1, 0])

    star = new Star(2, 2)
    # console.log(star)
    expect(star.starType).toBe('numbers')
    expect(star.indentLevel).toBe(2)
    expect(star.indentType).toBe('spaces')
    expect(star.startRow).toBe(2)
    expect(star.endRow).toBe(2)
    expect(star.starCol).toBe(4)
    expect(star.nextNumber).toBe(4)
    expect(star.startTextCol).toBe(7)

  it "finds a star at level 0 correctly", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* One")
    editor.setCursorBufferPosition([0, 0])

    star = new Star(0, 2)
    # console.log(star)
    expect(star.starType).toBe('*')
    expect(star.indentLevel).toBe(0)
    expect(star.indentType).toBe('none')
    expect(star.startRow).toBe(0)
    expect(star.endRow).toBe(0)
    expect(star.starCol).toBe(0)
    expect(star.startTextCol).toBe(2)

  it "finds a star at level 1 correctly", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* One\n  * Two")
    editor.setCursorBufferPosition([1, 0])

    star = new Star(1, 2)
    # console.log(star)
    expect(star.starType).toBe('*')
    expect(star.indentLevel).toBe(1)
    expect(star.indentType).toBe('spaces')
    expect(star.startRow).toBe(1)
    expect(star.endRow).toBe(1)
    expect(star.starCol).toBe(2)
    expect(star.startTextCol).toBe(4)

  it "finds a star at level 2 correctly", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* One\n  * Two\n    * Three")
    editor.setCursorBufferPosition([1, 0])

    star = new Star(2, 2)
    # console.log(star)
    expect(star.starType).toBe('*')
    expect(star.indentLevel).toBe(2)
    expect(star.indentType).toBe('spaces')
    expect(star.startRow).toBe(2)
    expect(star.endRow).toBe(2)
    expect(star.starCol).toBe(4)
    expect(star.startTextCol).toBe(6)

  it "find a level 0 star with a [TODO] correctly", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* [TODO] One")
    editor.setCursorBufferPosition([0, 0])

    star = new Star(0, 2)
    # console.log(star)
    expect(star.starType).toBe('*')
    expect(star.indentLevel).toBe(0)
    expect(star.indentType).toBe('none')
    expect(star.startRow).toBe(0)
    expect(star.endRow).toBe(0)
    expect(star.starCol).toBe(0)
    expect(star.startTodoCol).toBe(2)
    expect(star.startTextCol).toBe(9)

  it "find a level 0 star with a [DONE] correctly", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* [DONE] One")
    editor.setCursorBufferPosition([0, 0])

    star = new Star(0, 2)
    # console.log(star)
    expect(star.starType).toBe('*')
    expect(star.indentLevel).toBe(0)
    expect(star.indentType).toBe('none')
    expect(star.startRow).toBe(0)
    expect(star.endRow).toBe(0)
    expect(star.starCol).toBe(0)
    expect(star.startTodoCol).toBe(2)
    expect(star.startTextCol).toBe(9)

  it "find a level 0 star with a [COMPLETED] correctly", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* [COMPLETED] One")
    editor.setCursorBufferPosition([0, 0])

    star = new Star(0, 2)
    # console.log(star)
    expect(star.starType).toBe('*')
    expect(star.indentLevel).toBe(0)
    expect(star.indentType).toBe('none')
    expect(star.startRow).toBe(0)
    expect(star.endRow).toBe(0)
    expect(star.starCol).toBe(0)
    expect(star.startTodoCol).toBe(2)
    expect(star.startTextCol).toBe(14)

  it "find a level 0 star with a TODO correctly", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* TODO One")
    editor.setCursorBufferPosition([0, 0])

    star = new Star(0, 2)
    # console.log(star)
    expect(star.starType).toBe('*')
    expect(star.indentLevel).toBe(0)
    expect(star.indentType).toBe('none')
    expect(star.startRow).toBe(0)
    expect(star.endRow).toBe(0)
    expect(star.starCol).toBe(0)
    expect(star.startTodoCol).toBe(2)
    expect(star.startTextCol).toBe(7)

  it "find a level 0 star with a DONE correctly", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* DONE One")
    editor.setCursorBufferPosition([0, 0])

    star = new Star(0, 2)
    # console.log(star)
    expect(star.starType).toBe('*')
    expect(star.indentLevel).toBe(0)
    expect(star.indentType).toBe('none')
    expect(star.startRow).toBe(0)
    expect(star.endRow).toBe(0)
    expect(star.starCol).toBe(0)
    expect(star.startTodoCol).toBe(2)
    expect(star.startTextCol).toBe(7)

  it "find a level 0 star with a COMPLETED correctly", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* COMPLETED One")
    editor.setCursorBufferPosition([0, 0])

    star = new Star(0, 2)
    # console.log(star)
    expect(star.starType).toBe('*')
    expect(star.indentLevel).toBe(0)
    expect(star.indentType).toBe('none')
    expect(star.startRow).toBe(0)
    expect(star.endRow).toBe(0)
    expect(star.starCol).toBe(0)
    expect(star.startTodoCol).toBe(2)
    expect(star.startTextCol).toBe(12)

  it "finds a minus at level 0 correctly", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("- One")
    editor.setCursorBufferPosition([0, 0])

    star = new Star(0, 2)
    # console.log(star)
    expect(star.starType).toBe('-')
    expect(star.indentLevel).toBe(0)
    expect(star.indentType).toBe('none')
    expect(star.startRow).toBe(0)
    expect(star.endRow).toBe(0)
    expect(star.starCol).toBe(0)
    expect(star.startTextCol).toBe(2)

  it "finds a minus at level 1 correctly", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("- One\n  - Two")
    editor.setCursorBufferPosition([1, 0])

    star = new Star(1, 2)
    # console.log(star)
    expect(star.starType).toBe('-')
    expect(star.indentLevel).toBe(1)
    expect(star.indentType).toBe('spaces')
    expect(star.startRow).toBe(1)
    expect(star.endRow).toBe(1)
    expect(star.starCol).toBe(2)
    expect(star.startTextCol).toBe(4)

  it "finds a minus at level 2 correctly", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("- One\n  - Two\n    - Three")
    editor.setCursorBufferPosition([1, 0])

    star = new Star(2, 2)
    # console.log(star)
    expect(star.starType).toBe('-')
    expect(star.indentLevel).toBe(2)
    expect(star.indentType).toBe('spaces')
    expect(star.startRow).toBe(2)
    expect(star.endRow).toBe(2)
    expect(star.starCol).toBe(4)
    expect(star.startTextCol).toBe(6)

  it "can find the last line of an indented subtree", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* One\n  * Two\n    * Three\n* Four")
    editor.setCursorBufferPosition([0, 0])

    star = new Star(0, 2)
    expect(star.getEndOfSubtree()).toBe(2)

  it "can find the last line of a stacked subtree", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* One\n** Two\n*** Three\n* Four")
    editor.setCursorBufferPosition([0, 0])

    star = new Star(0, 2)
    expect(star.getEndOfSubtree()).toBe(2)

  it "can find the last line of a stacked when there isn't a following star", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* One\n** Two\n*** Three")
    editor.setCursorBufferPosition([0, 0])

    star = new Star(0, 2)
    expect(star.getEndOfSubtree()).toBe(2)

  it "can find the end of the subtree when there is only 1 line ", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* One")
    editor.setCursorBufferPosition([0, 0])

    star = new Star(0, 2)
    expect(star.getEndOfSubtree()).toBe(0)

  fit "returns the correct progress when there are brackets on the progress", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* [TODO] Test")
    editor.setCursorBufferPosition([0, 0])

    star = new Star(0, 2)
    expect(star.progress).toBe("TODO")
    expect(star.isDone()).toBe(false)

  it "returns the correct progress when there are brackets on the progress and its done", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* [DONE] Test")
    editor.setCursorBufferPosition([0, 0])

    star = new Star(0, 2)
    expect(star.progress).toBe("DONE")
    expect(star.isDone()).toBe(true)

  it "returns the correct progress when there are brackets on the progress and its done", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* [COMPLETED] Test")
    editor.setCursorBufferPosition([0, 0])

    star = new Star(0, 2)
    expect(star.progress).toBe("COMPLETED")
    expect(star.isDone()).toBe(true)

  it "returns the correct progress when there are brackets on the progress", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* TODO Test")
    editor.setCursorBufferPosition([0, 0])

    star = new Star(0, 2)
    expect(star.progress).toBe("TODO")
    expect(star.isDone()).toBe(false)

  it "returns the correct progress when there are brackets on the progress and its done", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* DONE Test")
    editor.setCursorBufferPosition([0, 0])

    star = new Star(0, 2)
    expect(star.progress).toBe("DONE")
    expect(star.isDone()).toBe(true)

  it "returns the correct progress when there are brackets on the progress and its done", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* COMPLETED Test")
    editor.setCursorBufferPosition([0, 0])

    star = new Star(0, 2)
    expect(star.progress).toBe("COMPLETED")
    expect(star.isDone()).toBe(true)

  it "can parse priority from a star", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* [TODO] [#A] Test")
    editor.setCursorBufferPosition([0, 0])

    star = new Star(0, 2)
    expect(star.priority).toBe("A")

  it "can recognize letters as stars", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("A. Test")
    editor.setCursorBufferPosition([0, 0])

    star = new Star(0, 2)
    expect(star.currentLetter).toBe("A")
    expect(star.nextLetter).toBe("B")
    expect(star.starType).toBe("letters")

  it "can handle second level letter", ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText("* Test 1\n  D. Test 2")
    editor.setCursorBufferPosition([0, 0])

    star = new Star(1, 4)
    expect(star.currentLetter).toBe("D")
    expect(star.nextLetter).toBe("E")
    expect(star.starType).toBe("letters")
