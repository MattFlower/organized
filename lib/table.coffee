class Table
  @editor = null
  @found = false
  @firstRow = -1
  @lastRow = -1
  @firstCol = -1
  @widestRowSize = 0
  @rows = {}

  constructor: (editor, startPosition=null) ->
    @rows = {}
    @editor = editor
    if not startPosition
      startPosition = editor.getCursorBufferPosition()

    # Find first border
    position = [startPosition.row, startPosition.column]
    scopes = editor.scopeDescriptorForBufferPosition(position).getScopesArray()
    while position[0] >= 0 and ('border.table.organized' in scopes or 'row.table.organized' in scopes)
      position = [position[0]-1, position[1]]
      scopes = editor.scopeDescriptorForBufferPosition(position).getScopesArray()

    if position[0]+1 >= 0
      @firstRow = position[0]+1
    else
      @found = false
      return

    # Find last border
    position = [startPosition.row, startPosition.column]
    scopes = editor.scopeDescriptorForBufferPosition(position).getScopesArray()

    while position[0] <= editor.getLastBufferRow() and ('border.table.organized' in scopes or 'row.table.organized' in scopes)
      if match = @lineMatchesTableBorderOrRow(editor.lineTextForBufferRow(position[0]))
        style = if match[0][0] is '+' then 'border' else 'row'
        @rows[position[0]] = [match[0].length, match.index, style]
        @widestRowSize = if @widestRowSize then Math.max(match[0].length, @widestRowSize) else match[0].length
      position = [position[0]+1, position[1]]
      scopes = editor.scopeDescriptorForBufferPosition(position).getScopesArray()

    if position[0] > editor.getLastBufferRow()
      @lastRow = editor.getLastBufferRow()
    else
      @lastRow = position[0]

    # Find first column
    position = [@firstRow.row, startPosition.column]
    scopes = editor.scopeDescriptorForBufferPosition(position).getScopesArray()
    while scopes[1] >= 0 and ('border.table.organized' in scopes or 'row.table.organized' in scopes)
      position = [position[0], position[1]-1]
      scopes = editor.scopeDescriptorForBufferPosition(position).getScopesArray()

    if position[1] >= 0
      @firstCol = position[1]
    else
      @found = false
      return

    @found = true

  normalizeRowSizes: () ->
    if editor = atom.workspace.getActiveTextEditor()
      position = editor.getCursorBufferPosition()
      if not @widestRowSize
        console.log("WidestRowSize not found")
        return
      for row in [@firstRow..@lastRow]
        if row is position.row
          continue
        if rowInfo = @rows[row]
          if rowInfo[0] is @widestRowSize
            continue

          console.log("Current size: #{rowInfo[0]}, max size: #{@widestRowSize}, type: #{rowInfo[2]}")

          indentColumn = rowInfo[0] + rowInfo[1] - 1
          position = [row, indentColumn]
          # console.log(scopes)
          if rowInfo[2] is 'border'
            editor.setTextInBufferRange([[row, indentColumn],[row, indentColumn]], "-")
          else if rowInfo[2] is 'row'
            editor.setTextInBufferRange([[row, indentColumn],[row, indentColumn]], " ")
        else
          console.log(@rows)
          console.log("No rowsize found.  rows: #{@rows}, row: #{row}")

  lineMatchesTableBorderOrRow: (line) ->
    return ///
      (\+[-|+]+\+)|
      (\|.+\|)
      ///.exec(line)

module.exports = Table
