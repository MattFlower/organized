class Table
  @editor = null
  @found = false
  @firstRow = -1
  @lastRow = -1
  @firstCol = -1

  constructor: (editor, startPosition=null) ->
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
      position = [position[0]+1, position[1]]
      scopes = editor.scopeDescriptorForBufferPosition(position).getScopesArray()

    if position[0] <= editor.getLastBufferRow()
      @lastRow = position[0]-1
    else
      @found = false
      return

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

  findRowColumns: (row=null) ->
    if not row
      position = @editor.getCursorBufferPosition()
      row = position.row

    line = @editor.lineTextForBufferRow(row)
    if match = /^[\|\+](\-+[\|\+])+$/.exec(line)
      return @_findColumns(match[0], match.index)
    else if match = /(\|)([^\-\+\|]+\|)+/.exec(line)
      return @_findColumns(match[0], match.index)
    else
      return null

  currentColumnIndex: (columns=null) ->
    position = @editor.getCursorBufferPosition()
    if not columns
      columns = @findRowColumns(position.row)
    column = -1

    # We skip the last row -- if they are beyond that, they aren't in the table
    for i in [0..columns.length-1]
      if columns[i] >= position.column
        column = i-1
        break

    return column

  _findColumns: (text, column=0) ->
    columns = []
    for i in [0..text.length-1]
      if text[i] in ['|', '+']
        columns.push(column+i)

    return columns


module.exports = Table
