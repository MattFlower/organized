spawn = require('child_process').spawn
tmp = require('tmp')
fs = require('fs')

#
# Centralize parsing and execution of code blocks
#
class CodeBlock
  @startCol: -1
  @startRow: -1
  @endRow: -1
  @language: null
  @editor: null
  @found: true

  constructor: (currentRow, editor = atom.workspace.getActiveTextEditor()) ->
    @editor = editor

    #Work backward to find start
    row = currentRow
    line = editor.lineTextForBufferRow(row)
    while row > 0 and not line.match(/^\s*(```|#\+BEGIN_SRC)/)
      row -= 1
      line = editor.lineTextForBufferRow(row)

    if match = /(?<=^\s*)(```|#\+BEGIN_SRC )(\S+)/.exec(line)
      @startRow = row
      @language = match[2]
      @startCol = match.index
    else
      return

    #Now work forward to find end
    row = currentRow
    line = editor.lineTextForBufferRow(row)
    while row < editor.getLastBufferRow() and not line.match(/^\s*(```|#\+END_SRC)/)
      row += 1
      line = editor.lineTextForBufferRow(row)

    if line.match(/^\s*(```|#\+END_SRC)/)
      @endRow = row
    else
      return

    @found = true

  execute: (resultBlock) ->
    if not @found
      console.error("Code block not found here")
      return

    # Grab the code, making sure to remove leading whitespace up to the column where
    # the open of the codeblock appears
    code = ""
    row = @startRow+1
    while row < @endRow
      code += @editor.getTextInBufferRange([[row, @startCol], [row, Infinity]]) + "\n"
      row += 1

    resultBlock = new ResultBlock(this, @editor)

    # Create a temp file to put the code in -- it's easier than trying to deal with
    # piping multiple lines to some execution engines
    tmp.file (err, path, fd, cleanupCallback) =>
      if err
        throw err

      fs.write fd, code, (err) =>
        if executor = @executionEngine()
          resultBlock.clearResultBlock()
          process = executor(path)
          process.stdout.on 'data', (data) ->
            resultBlock.addRow(data)
          process.stderr.on 'data', (data) ->
            resultBlock.addRow(data)
          process.on 'close', (code) ->
            if code isnt 0
              atom.notifications.addError("Process ended with code #{{code}}")
            cleanupCallback()
        else
          atom.notifications.addError("Language '#{@language}' is not recognized or not supported for code execution")

  executionEngine: () ->
    switch @language
      when 'python' then return (pathToFile) ->
          return spawn('python', [pathToFile])

      when 'shell' then return (pathToFile) ->
        return spawn('sh', [pathToFile])

      when 'bash' then return (pathToFile) ->
        return spawn('bash', [pathToFile])

      when 'coffee' then return (pathToFile) ->
        return spawn('coffee', [pathToFile])

      when 'javascript' then return (pathToFile) ->
        return spawn('node', [pathToFile])

      when 'js' then return (pathToFile) ->
        return spawn('node', [pathToFile])

      # when 'java' then return (pathToFile) ->
      #   process = spawn('javac', [pathToFile])
      #   process.stderr.on 'data', (data) ->
      #     return null
      #   process.on 'close', (code) ->
      #     if code isnt 0 return
      #
      #
      else return null

class ResultBlock
  @resultRow = -1
  @currentRow = -1
  @indentCol = -1
  @editor = null

  constructor: (codeBlock, editor = atom.workspace.getActiveTextEditor()) ->
    @editor = editor
    row = codeBlock.endRow+1
    line = editor.lineTextForBufferRow(row)
    while row < editor.getLastBufferRow() and not line.match(/^\s*(#\+RESULT|```result)/)
      row += 1
      line = editor.lineTextForBufferRow(row)

    if match = /(#\+RESULT|```result)/.exec(line)
      @resultRow = row
      @indentCol = match.index
      line = editor.lineTextForBufferRow(row)

  addError: (resultCode) ->
    if not @resultRow
      atom.notifications.addError("Process ended in error", { icon: 'alert', detail: "Result code: #{resultCode}"})

    @_addResult("!", result)

  addRow: (result) ->
    if not @resultRow
      atom.notifications.addInfo("Code Block Execution Output", { icon: 'playback-play', detail: result })
      return

    @_addResult(":", result)

  _addResult: (prefix, result) ->
    if not @currentRow
      @currentRow = @resultRow

    @editor.transact 1000, () =>
      @editor.setCursorBufferPosition([@currentRow, Infinity])
      @editor.insertNewline()
      @currentRow = @editor.getCursorBufferPosition().row
      result = "" + result
      #Strip trailing \n if it exists
      if result.endsWith("\n")
        result = result.substr(0, result.length-1)

      indent = " ".repeat(@indentCol)
      result = "#{prefix} #{result}"
      result = result.replace(/\n/g, "\n#{indent}#{prefix} ")
      @editor.insertText(result, {autoIndent: true})

  clearResultBlock: ->
    # Delete all rows that start with a colon
    if not @resultRow
      return

    row = @resultRow+1
    lastRow = -1
    while @editor.lineTextForBufferRow(row).match("\s*: ")
      lastRow = row
      row += 1

    if lastRow >= 0
      console.log("Clearing from #{@resultRow+1} to #{lastRow}")
      @editor.setTextInBufferRange([[@resultRow+1, 0],[lastRow+1, 0]], "")

module.exports = CodeBlock
