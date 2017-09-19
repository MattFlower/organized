class Table
  editor = null
  found = false
  firstRow = null
  lastRow = null

  constructor: (editor, startPosition=null) ->
    @rows = {}
    @editor = editor
    if not startPosition
      startPosition = editor.getCursorBufferPosition()

    position = [startPosition.row, startPosition.column]
    @found = @positionHasTable(position)
    if not @found
      return

    # Find start of table
    @firstRow = position[0]
    position[0] -= 1
    while position[0] >= 0 and @positionHasTable(position)
      @firstRow = position[0]
      position[0] -= 1

    # Find end of table
    position = [startPosition.row, startPosition.column]
    @lastRow = position[0]
    position[0] += 1
    while position[0] <= editor.getLastBufferRow() and @positionHasTable(position)
      @lastRow = position[0]
      position[0] += 1

  positionHasTable: (position) ->
    scopes = @editor.scopeDescriptorForBufferPosition(position).getScopesArray()
    return scopes.some (scope) => 'border.table.organized' == scope or 'row.table.organized' == scope

  rowInfo: (position) ->
    if not position.row or not position.column
      position = { row: position[0], column: position[1] }

    info = { found: false }

    # Parse a border line
    line = @editor.lineTextForBufferRow(position.row)
    if match = line.match(/(\+)(\-+)(?=\+)/g)
      console.log(match)
      info.found = true
      info.colCount = match.length
      return info

    # Parse a row line
    if match = line.match(/(\|)([^\|]+)(?=\|)/g)
      console.log(match)
      info.found = true
      info.colCount = match.length
      return info

    return info

module.exports = Table
