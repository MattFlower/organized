TextSearch = require('rx-text-search')

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

    @_findInDirectories directories, skipFiles, [], onComplete

  @_findInDirectories: (directories, skipFiles, todos, onComplete) ->
    if directories.length is 0
      onComplete(todos)
    else
      if typeof directories is 'string'
        path = directories
        directories = []
      else
        path = directories.pop()

      console.log("Finding TODO's in #{path}")
      TextSearch.findAsPromise("(\\[TODO\\].*)$", "**/*.org", {cwd: path, matchBase: true})
        .then (results) =>
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

            todos.push(new Todo(path + "/" + result.file, result.line, column, text))
          @_findInDirectories(directories, skipFiles, todos, onComplete)

module.exports = Todo
