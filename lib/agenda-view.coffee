{View} = require 'space-pen'

class AgendaView extends View
  @content: (agenda) ->
    @agenda = agenda

    @li class: 'organized-sidebar-agenda-item', =>
      if agenda.date.creationData().format.indexOf('HH:mm') > -1
        @a class: 'organized-sidebar-agenda-item-time', 'data-file': agenda.file, 'data-line': agenda.line, 'data-column': agenda.column, click: 'agendaItemClick', agenda.date.format("LT")
      else
        @a class: 'organized-sidebar-agenda-item-time', 'data-file': agenda.file, 'data-line': agenda.line, 'data-column': agenda.column, click: 'agendaItemClick', "ALL DAY"
      @span class: 'organized-sidebar-agenda-item-title', 'data-file': agenda.file, 'data-line': agenda.line, 'data-column': agenda.column, click: 'agendaItemClick', text: @raw(agenda.text)

  visibility: 'show'

  agendaItemClick: (event) ->
    file = event.target.dataset['file']
    line = event.target.dataset['line']
    column = event.target.dataset['column']

    options =
      initialLine: (1*line)-1
      initialColumn: 0
      pending: true
    atom.workspace.open file, options

module.exports = AgendaView
