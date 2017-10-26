Constants = require './constants'
{shell} = require 'electron'
moment = require 'moment'


#
# Centralize all the information about a star into one place so don't repeatedly
# search for the start of star in the editor.
#
class Star
  @_dateFormats = Constants.dateFormats
  startRow: -1
  endRow: -1
  starCol: -1
  whitespaceCol: -1
  startTodoCol: -1
  startTextCol: -1
  starType: null
  indentLevel: 0
  indentType: null
  defaultIndentType: null
  currentNumber: 0
  nextNumber: 0
  currentLetter: undefined
  nextLetter: undefined
  progress: null
  priority: "C"
  priorityPresent: false

  statusRow: -1
  scheduleDate: null
  closeDate: null

  latestRowSeen: -1
  indentSpaces: -1
  editor: null

  constructor: (currentRow, indentSpaces, defaultIndentType, editor = atom.workspace.getActiveTextEditor()) ->
    @latestRowSeen = currentRow
    @indentSpaces = indentSpaces

    if defaultIndentType is "whitespace"
      @defaultIndentType = if editor.getSoftTabs() then "spaces" else "tabs"
    else
      @defaultIndentType = defaultIndentType
    @editor = editor
    @_processStar()

  _deepSearchForStacked: () ->
    currentRow = @endRow + 1
    while currentRow < @editor.getLineCount()
      currentLine = @editor.lineTextForBufferRow(currentRow)
      if not currentLine.match(Constants.starWithTextRex)
        currentRow += 1
      else if star = new Star(currentRow, @indentSpaces, @defaultIndentType, @editor)
        if star.indentType == 'stacked'
          return true
        currentRow = star.endRow+1
      else
        currentRow += 1
    return false

  _processLine: (line) ->
    if not line
      return false

    # Find info about star
    @starCol = @_starIndexOf(line)

    #console.log("Found star on row #{@startRow} and col #{@starCol}")
    match = line.match(Constants.starWithBulletRex)
    ColNums = Constants.starWithBulletGroups

    if match
      @whitespaceCol = @starCol + match[ColNums.Star].length
      @startTodoCol = @whitespaceCol + 1
      if match[ColNums.ProgressWithWhitespace]
        @startTextCol = @startTodoCol + match[ColNums.ProgressWithWhitespace].length
      else
        @startTextCol = @startTodoCol

      if match[ColNums.Progress]
        @progress = match[ColNums.Progress].replace(/(\[|\])/g, '')

      # Grab the priority
      if match[ColNums.Priority]
        @priority = match[ColNums.Priority]
        @priorityPresent = true

      # Compute indent level
      levelCount = 0
      stars = match[ColNums.Star]
      starsAreNumbers = stars.match(/\d+\./)
      starsAreLetters = stars.match(/[A-z]\./)

      if not starsAreNumbers and not starsAreLetters and stars.length > 1
        # console.log("Stacked")
        @indentType = "stacked"
        @starType = stars[0]

        levelCount = 0
        #console.log("Stars.length: #{stars.length}")
        i = 1
        while i < stars.length
          #console.log("Index: #{i}, Length: #{stars.length}, StarType: #{@starType}, Current: #{stars[i]}")
          if stars[i] is @starType
            levelCount += 1
            i += 1
          else
            #Mix of different star types, reject
            levelCount = 0
            break
      else
        # console.log("spaces")
        levelCount = 0
        index = 0
        indentBySpaceString = " ".repeat(@indentSpaces)
        @indentType = "none"
        # console.log("indentSpaces: #{@indentSpaces}")
        while index < @starCol
          #console.log("Index: #{index}")
          if line[index] is '\t'
            #console.log("Found tab character")
            levelCount += 1
            index += 1
            @indentType = if @indentType in ["none", "tabs"] then "tabs" else "mixed"
          else if line[index..index+@indentSpaces-1] is indentBySpaceString
            #console.log("Found '#{line[index..index+@indentSpaces-1]}'")
            levelCount += 1
            index += @indentSpaces
            @indentType = if @indentType in ["none", "spaces"] then "spaces" else "mixed"
          else
            #console.log("Found unknown: '#{line[index..index+@indentSpaces-1]}', '#{line[index]}'")
            #Not really sure what to do with this.
            index += 1
            @indentType = "mixed"

        # Star type
        if starsAreNumbers
          @starType = "numbers"
          @currentNumber = parseInt(match[ColNums.StarNum], 10)
          @nextNumber = @currentNumber + 1
        else if starsAreLetters
          @starType = "letters"
          @currentLetter = match[ColNums.StarLetter]
          if @currentLetter is 'Z'
            @nextLetter is 'AA'
          else if @currentLetter is 'z'
            @nextLetter is 'ZZ'
          else
            @nextLetter = String.fromCharCode(@currentLetter.charCodeAt(0)+1)
        else
          @starType = stars

      @indentLevel = levelCount
      return true
    else
      return false

  _processStar: ->
    # Find starting row
    row = @latestRowSeen
    line = @editor.lineTextForBufferRow(row)
    #console.log("Row: #{row}, Line: #{line}")
    while line isnt null and !line.match(/^\s*([\*\-\+]+|\d+\.|[A-z]\.)([ ]|$)/)
      # console.log("No star on #{row}")
      row -= 1
      if row < 0 or line.match(/^(#|$)/)
        @startRow = -1
        return
      else
        line = @editor.lineTextForBufferRow(row)

    @startRow = row

    if @_processLine(line)
      # Look for closed or scheduled tags on the following line
      if @startRow
        statusLine = @editor.lineTextForBufferRow(@startRow+1)
        if match = /SCHEDULED: <([^>]+)>/.exec(statusLine)
          d = moment(match[1], @_dateFormats, false)
          if d.isValid()
            @scheduleDate = d.toDate()

        if match = /CLOSED: \(([^)]+)\)/.exec(statusLine)
          d = moment(match[1], @_dateFormats, false)
          if d.isValid()
            @closeDate = d.toDate()

      # End row
      #console.log("Row: #{@latestRowSeen}, Last: #{@editor.getLastBufferRow()}")
      row = Math.max(@latestRowSeen, @startRow + 1)
      line = @editor.lineTextForBufferRow(row)
      while row <= @editor.getLastBufferRow() and !line.match(Constants.emptyLineOrStarLineRex)
        #console.log("checked: '#{line}'")
        row += 1
        line = @editor.lineTextForBufferRow(row)

      @endRow = Math.max(0, row-1)
      @latestRowSeen = row

      # Try one more idea to figure out if we are actually stacked
      # We can't do this until now because we needed the endRow
      if @indentType is 'none' and @_deepSearchForStacked()
          @indentType = "stacked"

  _starIndexOf: (line) ->
    if match = Constants.starWithBulletNoMarkersRex.exec(line)
      # No match, ignore
      return 0 if match.length < 1
      # count the spaces
      return match[1].length
    else
      return 0

  decreasePriority: (editor) ->
    if not @priorityPresent
      newPriority = @getMinPriority()
    else if @priority == @getMinPriority()
      return @removePriority(editor)
    else
      newPriority = String.fromCharCode(@priority.charCodeAt()+1)

    line = editor.lineTextForBufferRow(@startRow)
    if match = new RegExp("\\[#"+@priority+"\\]").exec(line)
      editor.setTextInBufferRange([[@startRow, match.index+2], [@startRow, match.index+3]], newPriority)
    else
      editor.setTextInBufferRange([[@startRow, @startTextCol], [@startRow, @startTextCol]], "[##{newPriority}] ")

  # Find the last line at the same level as this star
  getEndOfSubtree: () ->
    currentLine = @endRow + 1
    while currentLine < @editor.getLineCount()
      if star = new Star(currentLine, @indentSpaces, @defaultIndentType, @editor)
        if star.indentLevel <= @indentLevel
          return currentLine-1
        else
          currentLine = star.endRow+1
    # We weren't able to find another star at the same level
    if currentLine >= @editor.getLineCount()
      currentLine = @editor.getLineCount()-1

    return currentLine

  getMaxPriority: () ->
    return "A"

  getMinPriority: () ->
    return "E"

  increasePriority: (editor) ->
    if not @priorityPresent
      newPriority = @getMaxPriority()
    else if @priority == @getMaxPriority()
      return @removePriority(editor)
    else
      newPriority = String.fromCharCode(@priority.charCodeAt()-1)

    line = editor.lineTextForBufferRow(@startRow)
    if match = new RegExp("\\[#"+@priority+"\\]").exec(line)
      editor.setTextInBufferRange([[@startRow, match.index+2], [@startRow, match.index+3]], newPriority)
    else
      editor.setTextInBufferRange([[@startRow, @startTextCol], [@startRow, @startTextCol]], "[##{newPriority}] ")

  isDone: () ->
    return @progress and (@progress is "DONE" or @progress is 'COMPLETED')

  newStarLine: (indentLevel = @indentLevel) ->
    if @indentType isnt "mixed"
      indentStyle = @indentType
    else
      indentStyle = @defaultIndentType

    if indentStyle is "stacked"
      indent = @starType.repeat(@indentLevel+1) + " "
    else
      if indentStyle is "spaces"
        indent = " ".repeat(@indentSpaces*@indentLevel)
      else if indentStyle is "tabs"
        indent = "\t".repeat(@indentLevel)
      else if indentStyle is "none"
        indent = ""

      if @starType is "numbers"
        indent += @nextNumber + '. '
      else if @starType is "letters"
        indent += @nextLetter + '. '
      else
        indent += @starType + " "

    return indent

  removePriority: (editor) ->
    line = editor.lineTextForBufferRow(@startRow)
    if match = new RegExp("\\[#"+@priority+"\\]\\s+").exec(line)
      editor.setTextInBufferRange([[@startRow, match.index], [@startRow, match.index + match[0].length]], "")

module.exports = Star
