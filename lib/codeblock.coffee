spawn = require('child_process').spawn
spawnSync = require('child_process').spawnSync
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

    if match = /(^\s*)(```|#\+BEGIN_SRC )(\S+)/.exec(line)
      @startRow = row
      @language = match[3]
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

    # Java files need a particular name, extract that
    tmpDir = tmp.dirSync()
    dirname = tmpDir.name
    console.log("Dir: #{dirname}")
    if @language is 'java'
      if match = code.match(/public\s+class\s+(\S+)/)
        filename = dirname + "/" + match[1] + ".java"
      else
        atom.notifications.addError("Could not public class name for Java snippet")
        tmpDir.removeCallback()
        return
    else if @language is 'c'
      filename = tmp.tmpNameSync({dir: dirname}) + ".c"
    else if @language is 'cpp'
      filename = tmp.tmpNameSync({dir: dirname}) + ".cpp"
    else if @language in ['go', 'golang']
      filename = tmp.tmpNameSync({dir: dirname}) + ".go"
    else if @language is 'objc'
      filename = tmp.tmpNameSync({dir: dirname}) + ".m"
    else
      filename = tmp.tmpNameSync({dir: dirname})
    console.log("Filename: #{filename}")
    removeCallback = () =>
      #spawn("rm", ['-r', dirname])

    # Execute the block
    fs.open filename, 'wx', (err, fd) =>
      if err
        removeCallback()
        throw err

      fs.write fd, code, (err) =>
        if executor = @executionEngine()
          resultBlock.clearResultBlock()
          if process = executor(filename, resultBlock)
            process.stdout.on 'data', (data) ->
              resultBlock.addRow(data)
            process.stderr.on 'data', (data) ->
              resultBlock.addError(data)
            process.on 'close', (code) ->
              if code isnt 0
                atom.notifications.addError("Process ended with code #{{code}}")
              removeCallback()
          else
            removeCallback()
        else
          atom.notifications.addError("Language '#{@language}' is not recognized or not supported for code execution")

    # Create a temp file to put the code in -- it's easier than trying to deal with
    # piping multiple lines to some execution engines

  executionEngine: () ->
    switch @language
      when 'bash' then return (pathToFile, resultBlock) ->
        return spawn('bash', [pathToFile])

      when 'c' then return (pathToFile, resultBlock) ->
        if match = pathToFile.match(/^(.*)\/[^/]+$/)
          dirName = match[1]
          outputFile = "#{dirName}/test"
          ccProcess = spawnSync("cc", [pathToFile, '-o', outputFile])
          if ccProcess.status
            resultBlock.addError("Result code is #{ccProcess.signal}")
            resultBlock.addError(ccProcess.stderr)
            return null
          else
            return spawn(outputFile)

      when 'coffee' then return (pathToFile, resultBlock) ->
        return spawn('coffee', [pathToFile])

      when 'cpp' then return (pathToFile, resultBlock) ->
        if match = pathToFile.match(/^(.*)\/[^/]+$/)
          dirName = match[1]
          outputFile = "#{dirName}/test"
          cppProcess = spawnSync("g++", [pathToFile, '-o', outputFile])
          if cppProcess.status
            resultBlock.addError("Result code is #{cppProcess.signal}")
            resultBlock.addError(cppProcess.stderr)
            return null
          else
            return spawn(outputFile)

      # I can't figure out how the 'or' syntax works in coffeescript, I'll just leave two copies for now
      # because they are short.
      when 'go' then return (pathToFile, resultBlock) ->
        return spawn('go', ['run', pathToFile])

      when 'golang' then return (pathToFile, resultBlock) ->
        return spawn('go', ['run', pathToFile])

      when 'java' then return (pathToFile, resultBlock) ->
        if match = pathToFile.match(/^(.*)\/([^/]+).java$/)
          dirName = match[1]
          className = match[2]
          javacProcess = spawnSync("javac", [pathToFile])
          if javacProcess.status
            resultBlock.addError("Result code is #{javacProcess.status}")
            resultBlock.addError(javacProcess.stderr)
            return null
          else
            return spawn('java', ['-cp', dirName, className])
        else
          atom.notifications.addError("Cannot find Java class name")
          return null

      when 'javascript' then return (pathToFile, resultBlock) ->
        return spawn('node', [pathToFile])

      when 'js' then return (pathToFile, resultBlock) ->
        return spawn('node', [pathToFile])

      when 'objc' then return (pathToFile, resultBlock) ->
        if match = pathToFile.match(/^(.*)\/[^/]+$/)
          dirName = match[1]
          outputFile = "#{dirName}/test"
          ccProcess = spawnSync("clang", ['-o', outputFile, '-lobjc', '-framework', 'Foundation', pathToFile])
          if ccProcess.status
            resultBlock.addError("Result code is #{ccProcess.signal}")
            resultBlock.addError(ccProcess.stderr)
            return null
          else
            return spawn(outputFile)

      when 'perl' then return (pathToFile, resultBlock) ->
        return spawn('perl', [pathToFile])

      when 'php' then return (pathToFile, resultBlock) ->
        return spawn('php', [pathToFile])

      when 'python' then return (pathToFile, resultBlock) ->
          return spawn('python', [pathToFile])

      when 'r' then return (pathToFile, resultBlock) ->
          return spawn('Rscript', [pathToFile])

      when 'shell' then return (pathToFile, resultBlock) ->
        return spawn('sh', [pathToFile])

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
      if line.match(/^\s*(```|#BEGIN_SRC)/)
        #Another code block is starting.  Our code block must not have one.
        return

      row += 1
      line = editor.lineTextForBufferRow(row)

    if match = /(#\+RESULT|```result)/.exec(line)
      @resultRow = row
      @indentCol = match.index
      line = editor.lineTextForBufferRow(row)

  addError: (result) ->
    if not @resultRow
      atom.notifications.addError("Process ended in error", { icon: 'alert', detail: result})
      return

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
    while @editor.lineTextForBufferRow(row).match("\s*[:!] ")
      lastRow = row
      row += 1

    if lastRow >= 0
      console.log("Clearing from #{@resultRow+1} to #{lastRow}")
      @editor.setTextInBufferRange([[@resultRow+1, 0],[lastRow+1, 0]], "")

module.exports = CodeBlock
