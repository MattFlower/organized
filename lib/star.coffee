{shell} = require 'electron'

#
# Centralize all the information about a star into one place so don't repeatedly
# search for the start of star in the editor.
#
class Star
  @startRow: -1
  @endRow: -1
  @starCol: -1
  @whitespaceCol: -1
  @startTextCol: -1
  @starType: null
  @indentLevel: 0
  @indentType: null
  @defaultIndentType: null
  @currentNumber: 0
  @nextNumber: 0

  @latestRowSeen: -1
  @indentSpaces: -1
  @editor: null

  constructor: (currentRow, indentSpaces, defaultIndentType, editor = atom.workspace.getActiveTextEditor()) ->
    @latestRowSeen = currentRow
    @indentSpaces = indentSpaces

    if defaultIndentType is "whitespace"
      @defaultIndentType = if editor.getSoftTabs() then "spaces" else "tabs"
    else
      @defaultIndentType = defaultIndentType
    @editor = editor
    @_processStar()

  _processStar: ->
    # Find starting row
    row = @latestRowSeen
    line = @editor.lineTextForBufferRow(row)
    #console.log("Row: #{row}, Line: #{line}")
    while !line.match(/^\s*([\*\-\+]+|\d+\.)([ ]|$)/)
      # console.log("No star on #{row}")
      row -= 1
      if row < 0 or line.match(/^(#|$)/)
        @startRow = -1
        return
      else
        line = @editor.lineTextForBufferRow(row)

    @startRow = row

    # Find info about star
    @starCol = @_starIndexOf(line)

    #console.log("Found star on row #{@startRow} and col #{@starCol}")

    line = @editor.lineTextForBufferRow(@startRow)
    match = line.match(/^(\s*)([\*\-\+]+|(\d+)\.)([ ]|$)(\[TODO\] |\[COMPLETED\] )?/)

    #console.log(match)

    if match
      @whitespaceCol = @starCol + match[2].length
      if match[4]
        @startTextCol = @whitespaceCol + match[4].length
      else
        @startTextCol = @whitespaceCol
      # Compute indent level
      levelCount = 0
      stars = match[2]
      starsAreNumbers = stars.match(/\d+\./)
      if not starsAreNumbers and stars.length > 1
        # console.log("Stacked")
        @indentType = "stacked"
        @starType = stars[0]

        levelCount = 1
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
          @currentNumber = parseInt(match[3], 10)
          @nextNumber = @currentNumber + 1
        else
          @starType = stars

      @indentLevel = levelCount

      # End row
      #console.log("Row: #{@latestRowSeen}, Last: #{@editor.getLastBufferRow()}")
      row = Math.max(@latestRowSeen, @startRow + 1)
      line = @editor.lineTextForBufferRow(row)
      while row <= @editor.getLastBufferRow() and !line.match(/(^$)|(^\s*([\*\-\+\#]|\d+\.))/)
        #console.log("checked: '#{line}'")
        row += 1
        line = @editor.lineTextForBufferRow(row)

      @endRow = Math.max(0, row-1)
      @latestRowSeen = row

  _starIndexOf: (line) ->
    match = /^(\s*)([\*\-\+]|\d+\.)/.exec(line)
    # No match, ignore
    return 0 if match.length < 1
    # count the spaces
    return match[1].length

  newStarLine: (indentLevel = @indentLevel) ->
    if @indentType isnt "mixed"
      indentStyle = @indentType
    else
      indentStyle = @defaultIndentType

    if indentStyle is "stacked"
      indent = @starType.repeat(@indentLevel) + " "
    else
      if indentStyle is "spaces"
        indent = " ".repeat(@indentSpaces*@indentLevel)
      else if indentStyle is "tabs"
        indent = "\t".repeat(@indentLevel)
      else if indentStyle is "none"
        indent = ""

      if @starType is "numbers"
        indent += @nextNumber + '. '
      else
        indent += @starType + " "

    return indent

module.exports = Star
