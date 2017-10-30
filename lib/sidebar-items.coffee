fs = require('fs')
path = require('path')
{ Trie } = require './trie'
{ findInDirectory, findInFile, findInFileContents } = require './item-finder'

class AgendaItem
  file: null
  line: null
  column: null
  date: null
  text: null

  constructor: (file, line, column, date, text) ->
    @file = file
    @line = line
    @column = column
    @date = date
    @text = text


class Todo
  file: null
  line: null
  column: null
  text: null
  priority: null

  constructor: (file, line, column, text, priority) ->
    @file = file
    @line = line
    @column = column
    @text = text
    @priority = priority


findInDirectories = (directories = atom.project.getPaths(), onComplete, readCurrentBuffer = true) ->
  skipFiles = atom.config.get('organized.searchSkipFiles')
  skipFiles = skipFiles.concat(['.git', '.atom'])
  skipFiles = (skipFile for skipFile in skipFiles when skipFile.trim() isnt '')

  # Eliminate duplicate directories, but do it in a stable way.
  # Additionally, and perhaps more importantly, if you have two directories and one is a
  # subdirectory of another one, eliminate the subdirectory so we don't visit the subdirectory
  # twice.  While we're at it, normalize the path so no ../ or ./ trickery will work.
  trie = new Trie()
  for directory in directories
    directory = path.normalize(directory)
    # End with a slash.  By doing this, we prevent matches between things like /home and /homely
    directoryWithSlash = if directory.endsWith(path.sep) then directory else directory + path.sep
    trie.add(directoryWithSlash)

  noDupesDirectory = []
  for directory in directories
    directory = path.normalize(directory)
    directoryWithSlash = if directory.endsWith(path.sep) then directory else directory + path.sep
    if not trie.hasPrefix(directoryWithSlash) and noDupesDirectory.indexOf(directory) is -1
      noDupesDirectory.push(directory)

  console.log("Finding in directories: #{noDupesDirectory}")
  _findInDirectories noDupesDirectory, skipFiles, [], [], onComplete, readCurrentBuffer

_findInDirectories = (directories, skipFiles, todos, agendas, onComplete, readCurrentBuffer, filesVisited = new Set()) ->
  if directories.length is 0
    onComplete(todos, agendas)
  else
    skipFileCB = (filename) =>
      skip = false
      if filesVisited.has(filename)
        skip = true
      else if skipFiles.indexOf(path.basename(filename)) > -1
        skip = true
      else
        skip = false
      filesVisited.add(filename)

      return skip

    todoCB = (filename, line, column, todoText, priority) =>
      # console.log("#{filename}[#{line}:#{column}] -> #{todoText}")
      todoText = _cleanupSideitemTitles(todoText)
      todos.push(new Todo(filename, line, column, todoText, priority))

    agendaCB = (filename, line, column, agendaText, time) =>
      # console.log("#{filename}[#{line}:#{column}] -> #{agendaText} @ #{time}")
      agendaText = _cleanupSideitemTitles(agendaText)
      agendas.push(new AgendaItem(filename, line, column, time, agendaText))

    errorCB = (filename, error) =>
      error = "Error finding todos in  " + searchPath + ".  Please check that directory exists and is writable."
      # atom.notifications.addError(error)
      _findInDirectories(directories, skipFiles, todos, agendas, onComplete, readCurrentBuffer, filesVisited)

    finishCB = () =>
      _findInDirectories(directories, skipFiles, todos, agendas, onComplete, readCurrentBuffer, filesVisited)

    editor = atom.workspace.getActiveTextEditor()
    if readCurrentBuffer and editor and editor.getGrammar().name is 'Organized'
      filename = editor.getPath()
      if not skipFileCB(filename)
        lines = editor.getText().split('\n')
        findInFileContents(filename, lines, todoCB, agendaCB)

    if typeof directories is 'string'
      searchPath = directories
      directories = []
    else
      searchPath = directories.pop()

      search = searchPath.trim()
      if searchPath.length is 0
        if directories.length > 0
          _findInDirectories(directories, skipFiles, todos, agendas, onComplete, readCurrentBuffer, filesVisited)
        else
          onComplete(todos, agendas)

    fs.lstat searchPath, (err, pathStat) =>
      if err
        errorCB(searchPath, err)
      else if pathStat.isDirectory()
        findInDirectory searchPath, skipFileCB, todoCB, agendaCB, errorCB, finishCB
      else if pathStat.isFile()
        findInFile searchPath, skipFileCB, todoCB, agendaCB, errorCB, finishCB

_cleanupSideitemTitles = (title) ->
  if match = /\[([^\]]+?)\]\(([^)]+?)\)/g.exec(title)
    linktitle = match[1]
    url = match[2]
    title = title.replace(/\[[^\]]+?\]\([^)]+?\)/, "<a href=\"#{url}\">#{linktitle}</a>")

  if match = /__([^_]+)__/g.exec(title)
    title = title.replace(/__[^_]+?__/, "<b>"+match[1]+"</b>")

  if match = /_([^_]+)_/g.exec(title)
    title = title.replace("/_[^_]+?_/", "<u>" + match[1] + "</u>")

  if match = /^\[?TODO\]? /.exec(title)
    title = title.replace(/\[?TODO\]? /, "")

  if match = /^\[?DONE\]? /.exec(title)
    title = title.replace(/\[?DONE\]? /, "")

  return title

module.exports = { Todo, findInDirectories }
