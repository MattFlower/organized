path = require 'path'
{ findInDirectory, findInFile } = require '../lib/item-finder'

resourceDir = path.resolve(path.dirname(__filename) + "/../spec-resources/item-finder-spec")
altResourceDir = path.resolve(path.dirname(__filename) + "/../spec-resources/item-finder-spec-alt")

describe "It can find items", ->
  it "locates todo and agenda items with findInDirectory", ->
    todoCount = 0
    agendaCount = 0
    errorCount = 0

    todoCB = (filename, line, column, todoText, priority) =>
      todoCount++

    agendaCB = (filename, line, column, agendaText, time) =>
      agendaCount++

    errorCB = (filename, error) =>
      errorCount++

    waitsForPromise ->
      new Promise (resolve, reject) =>
        finishCB = () =>
          resolve()
        findInDirectory(resourceDir, [], todoCB, agendaCB, errorCB, finishCB)
      .then () =>
        expect(todoCount).toBe(3) # One from test1.org, one from softlink, one from file with space
        expect(agendaCount).toBe(1)
        expect(errorCount).toBe(0)

  it "loads a todo from a file", ->
    todoCount = 0
    filename = undefined
    todoLine = undefined
    todoCol = undefined
    todoText = undefined
    todoPriority = undefined
    agendaCount = 0
    errorCount = 0

    todoCB = (file, line, column, text, priority) =>
      filename = file
      todoLine = line
      todoCol = column
      todoText = text
      todoPriority = priority
      todoCount++

    agendaCB = (filename, line, column, agendaText, time) =>
      agendaCount++

    errorCB = (filename, error) =>
      errorCount++

    waitsForPromise ->
      new Promise (resolve, reject) =>
        finishCB = () =>
          resolve()
        findInFile(path.join(resourceDir, 'test1.org'), [], todoCB, agendaCB, errorCB, finishCB)
      .then () =>
        expect(todoCount).toBe(1)
        expect(agendaCount).toBe(1)
        expect(errorCount).toBe(0)
        expect(path.basename(filename)).toBe('test1.org')
        expect(todoLine).toBe(1)
        expect(todoCol).toBe(2)
        expect(todoText).toBe("Todo1")

  xit "skips files with permission problems", ->
    # Disabled most of the time because it's hard to check out a file you don't own.  

    # If this test fails, make sure you have:
    # sudo chown root spec-resources/item-finder-spec/no-permissions.org && \
    #   sudo chmod 700 spec-resources/item-finder-spec/no-permissions.org

    todoCount = 0
    agendaCount = 0
    errorCount = 0

    todoCB = (filename, line, column, todoText, priority) =>
      todoCount++

    agendaCB = (filename, line, column, agendaText, time) =>
      agendaCount++

    waitsForPromise ->
      new Promise (resolve, reject) =>
        errorCB = (filename, error) =>
          errorCount++
          resolve()

        finishCB = () =>
          resolve()

        findInFile(path.join(altResourceDir, 'no-permissions.org'), [], todoCB, agendaCB, errorCB, finishCB)
      .then () =>
        expect(todoCount).toBe(0)
        expect(agendaCount).toBe(0)
        expect(errorCount).toBe(1)

  it "handles errors (like missing file errors)", ->
    todoCount = 0
    agendaCount = 0
    errorCount = 0

    todoCB = (filename, line, column, todoText, priority) =>
      todoCount++

    agendaCB = (filename, line, column, agendaText, time) =>
      agendaCount++

    waitsForPromise ->
      new Promise (resolve, reject) =>
        errorCB = (filename, error) =>
          errorCount++
          resolve()

        finishCB = () =>
          resolve()

        findInFile(path.join(altResourceDir, 'not-a-real-file.org'), [], todoCB, agendaCB, errorCB, finishCB)
      .then () =>
        expect(todoCount).toBe(0)
        expect(agendaCount).toBe(0)
        expect(errorCount).toBe(1)
