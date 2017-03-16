TextSearch = require('rx-text-search')
fs = require('fs')
path = require('path')

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

  @findInDirectories: (directories = atom.project.getPaths(), onComplete) ->
    skipFiles = atom.config.get('organized.searchSkipFiles')
    skipFiles = skipFiles.concat(['.git', '.atom'])
    skipFiles = (skipFile for skipFile in skipFiles when skipFile.trim() isnt '')

    console.log("Project paths: #{directories}")
    @_findInDirectories directories, skipFiles, [], onComplete

  @_findInDirectories: (directories, skipFiles, todos, onComplete) ->
    if directories.length is 0
      onComplete(todos)
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
          @_findInDirectories(directories, skipFiles, todos, onComplete)
        else if pathStat.isDirectory()
          console.log("Finding TODO's in #{searchPath}")
          TextSearch.findAsPromise("(\\[TODO\\].*)$", "**/*.org", {cwd: searchPath, matchBase: true})
            .then (results) =>
              @_processFile(searchPath, results, todos, skipFiles)
              @_findInDirectories(directories, skipFiles, todos, onComplete)
        else if pathStat.isFile()
          console.log("Finding TODO's in file #{searchPath}")
          TextSearch.findAsPromise("(\\[TODO\\].*)$", searchPath, {matchBase: true})
            .then (results) =>
              @_processFile(searchPath, results, todos, skipFiles)
              @_findInDirectories(directories, skipFiles, todos, onComplete)

  @_processFile: (searchPath, results, todos, skipFiles) ->
    for result in results
      skip = false
      for partial in skipFiles
        if result.file.indexOf(partial) > -1
          skip = true
          break;
      if skip
        continue

      text = result.text
      # if match = result.text.match(/(\[TODO\])\s+(.*)$/)
      #     text = match[2]
      if match = /(\[TODO\])\s+(.*)$/.exec(result.text)
          text = match[2]
          column = match.index

      referencedFile = result.file
      if not path.isAbsolute(result.file)
        referencedFile = path.join(searchPath, result.file)

      todos.push(new Todo(referencedFile, result.line, column, text))


module.exports = Todo
