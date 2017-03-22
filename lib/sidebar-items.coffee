TextSearch = require('rx-text-search')
fs = require('fs')
moment = require 'moment'
path = require('path')


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

  constructor: (file, line, column, text) ->
    @file = file
    @line = line
    @column = column
    @text = text


findInDirectories: (directories = atom.project.getPaths(), onComplete) ->
  skipFiles = atom.config.get('organized.searchSkipFiles')
  skipFiles = skipFiles.concat(['.git', '.atom'])
  skipFiles = (skipFile for skipFile in skipFiles when skipFile.trim() isnt '')

  console.log("Project paths: #{directories}")
  _findInDirectories directories, skipFiles, [], [], onComplete

_findInDirectories = (directories, skipFiles, todos, agendas, onComplete) ->
  if directories.length is 0
    onComplete(todos, agendas)
  else
    if typeof directories is 'string'
      searchPath = directories
      directories = []
    else
      searchPath = directories.pop()

    fs.lstat searchPath, (err, pathStat) =>
      if err
        error = "Error finding todos in  " + searchPath + ".  Please check that directory exists and is writable."
        atom.notifications.addError(error)
        _findInDirectories(directories, skipFiles, todos, agendas, onComplete)
      else if pathStat.isDirectory()
        console.log("Finding TODO's in #{searchPath}")
        TextSearch.findAsPromise(["(\\[TODO\\].*)$", "(SCHEDULED: <[^>]+>)"], "**/*.org", {cwd: searchPath, matchBase: true})
          .then (results) =>
            _processFile(searchPath, results, todos, agendas, skipFiles)
            _findInDirectories(directories, skipFiles, todos, agendas, onComplete)
      else if pathStat.isFile()
        console.log("Finding TODO's in file #{searchPath}")
        TextSearch.findAsPromise(["(\\[TODO\\].*)$", "(SCHEDULED: <[^>]+>)"], searchPath, {matchBase: true})
          .then (results) =>
            _processFile(searchPath, results, todos, agendas, skipFiles)
            _findInDirectories(directories, skipFiles, todos, agendas, onComplete)

dateFormats = ['YYYY-MM-DD ddd HH:mm:ss', 'YYYY-MM-DD ddd HH:mm', 'YYYY-MM-DD ddd', moment.ISO_8601]

findInDirectories = (directories = atom.project.getPaths(), onComplete) ->
  skipFiles = atom.config.get('organized.searchSkipFiles')
  skipFiles = skipFiles.concat(['.git', '.atom'])
  skipFiles = (skipFile for skipFile in skipFiles when skipFile.trim() isnt '')

  console.log("Project paths: #{directories}")
  _findInDirectories directories, skipFiles, [], [], onComplete

_cleanupSideitemTitles = (title) ->
  if match = /\[([^)]+)\]\(([^)]+)\)/g.exec(title)
    linktitle = match[1]
    url = match[2]
    title = title.replace(/\[[^)]+\]\([^)]+\)/, "<a href=\"#{url}\">#{linktitle}</a>")

  if match = /__([^_]+)__/g.exec(title)
    title = title.replace(/__[^_]+__/, "<b>"+match[1]+"</b>")

  if match = /_([^_]+)_/g.exec(title)
    title = title.replace("/_[^_]+_/", "<u>" + match[1] + "</u>")

  return title

_getFileLine = (filename, line, onFind) ->
  fileContents = fs.readFileSync filename
  lines = fileContents.toString().split('\n')

  if lines.length-1 < line
    return null
  else
    return lines[line]

_processFile = (searchPath, results, todos, agendas, skipFiles) ->
  for result in results
    skip = false
    for partial in skipFiles
      if result.file.indexOf(partial) > -1
        skip = true
        break;
    if skip
      continue

    text = result.text
    referencedFile = result.file
    if not path.isAbsolute(result.file)
      referencedFile = path.join(searchPath, result.file)
    # if match = result.text.match(/(\[TODO\])\s+(.*)$/)
    #     text = match[2]
    if match = /(\[TODO\])\s+(.*)$/.exec(result.text)
        text = match[2]
        column = match.index
        todoText = _cleanupSideitemTitles(text)
        todos.push(new Todo(referencedFile, result.line, column, todoText))
    else if match = /SCHEDULED: <([^>]+)>/.exec(result.text)
        date = match[1]
        parsedDate = moment(date, dateFormats)
        if not parsedDate.isValid()
          parsedDate = null
        column = match.index
        # This part is painful.  We're going to need to write our own search function to make this
        # suck less
        item = ""
        if starline = _getFileLine(referencedFile, result.line-2)
          if match = starline.match(/^(\s*)([\*\-\+]+|(\d+)\.)([ ]|$)(\[TODO\] |\[(COMPLETED|DONE)\] )?(.*)/)
            item = match[7]

        agendaText = _cleanupSideitemTitles(item)
        agendas.push(new AgendaItem(referencedFile, result.line, column, parsedDate, agendaText))


module.exports = { Todo, findInDirectories }
