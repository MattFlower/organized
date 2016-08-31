TextSearch = require('rx-text-search')

class Todo
  file: null
  line: null
  text: null

  constructor: (file, line, text) ->
    @file = file
    @line = line
    @text = text

  @findInDirectories: (directories = atom.project.getPaths(), onComplete) ->
    @_findInDirectories directories, [], (todos) ->
        for todo in todos
          console.log("#{todo.file}:#{todo.line} #{todo.text}")

  @_findInDirectories: (directories, todos, onComplete) ->
    if directories.length is 0
      onComplete(todos)
    else
      path = directories.pop()
      TextSearch.findAsPromise("(\\[TODO\\].*)$", "**/*.org", {cwd: path})
        .then (results) =>
          for result in results
            todos.push(new Todo(path + "/" + result.file, result.line, result.text))
          @_findInDirectories(directories, todos, onComplete)

module.exports = Todo
