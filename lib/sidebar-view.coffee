{$, View} = require 'atom-space-pen-views'
Todo = require './todo'
TodoView = require './todo-view'
{Emitter} = require 'event-kit'

module.exports =
class SidebarView extends View
  searchDirectories: null
  searchSkipFiles: null
  view: null
  sidebarVisible: false
  includeProjectPaths: true

  @content: ->
    @div class: 'organized-sidebar', tabindex: -1, outlet: 'sidebar', =>
      @div class: 'organized-sidebar-resize-handle', mousedown: 'resizeStarted', outlet: 'resizeHandle'
      @div class: 'organized-sidebar-todo', =>
        @div class: 'organized-sidebar-todo-header', =>
          @span class: 'todo-title-icon fa fa-2x fa-check-square-o'
          @span class: 'todo-title', 'Todo Items'
          @span class: 'close-button icon icon-remove-close', click: 'minimize'
          @span class: 'refresh-button icon icon-sync', click: 'refreshTodos'
        @div class: 'organized-sidebar-todo-items', =>
          @ul class: 'organized-sidebar-todo-list', outlet: 'todolist'

  # Activate is called by the main activate functionality so it can control it's
  # own interaction with the rest of the system.
  activate: (subscriptions) ->
    subscriptions.add atom.config.observe 'organized.includeProjectPathsInSearchDirectories', (newValue) =>
      @includeProjectPaths = newValue

    subscriptions.add atom.config.observe 'organized.sidebarVisible', (newValue) =>
      @sidebarVisible = newValue

    subscriptions.add atom.config.observe 'organized.searchDirectories', (newValue) =>
      @searchDirectories = newValue

    subscriptions.add atom.config.observe 'organized.searchSkipFiles', (newValue) =>
      newValue.filter (value) =>
        value.trim() isnt ""
      @searchSkipFiles = newValue

    subscriptions.add(atom.commands.add('atom-workspace', { 'organized:toggleSidebar': (event) => @toggleVisibility() }))

  constructor: ->
    super
    @emitter = new Emitter

  clearTodos: ->
    @todolist.empty()

  destroy: ->
    @view.hide()
    @view.destroy()

  initialize: () ->
    @view ?= atom.workspace.addRightPanel(item: @, visible: atom.config.get('organized.sidebarVisible'))

  minimize: () ->
    @view.hide()
    # @addClass 'minimize'
    # @.hide 'fast'
    @sidebarVisible = false
    atom.config.set('organized.sidebarVisible', false)
    @emitter.emit 'did-hide', @

  onDidHide: (callback) ->
    @emitter.on 'did-hide', callback

  onDidShow: (callback) ->
    @emitter.on 'did-show', callback

  refreshTodos: () ->
    @clearTodos()
    @populateTodos()

  # My resize implementation was lifted from tree-view.
  #
  # I added the use of -webkit-user-select to prevent the selection of text.  I know that
  # tree view does this somehow too, but I'm not entirely sure how.  It might be through
  # cancelling some event handlers, but I couldn't seem to replicate their success.
  resizeSidebar: ({pageX, which}) =>
    return @resizeStopped unless which is 1
    width = @outerWidth() + @offset().left - pageX
    @width(width)

  resizeStarted: () =>
    $('div.organized-sidebar').css('-webkit-user-select', 'none')
    $(document).on('mousemove', @resizeSidebar)
    $(document).on('mouseup', @resizeStopped)

  resizeStopped: () =>
    $('div.organized-sidebar').css('-webkit-user-select', 'auto')
    $(document).off('mousemove', @resizeSidebar)
    $(document).off('mouseup', @resizeStopped)

  populateTodos: () ->
    directories = []

    # Current open projects
    if @includeProjectPaths
      directories = directories.concat(atom.project.getPaths())

    # Search directories user has defined
    if @searchDirectories
      directories = directories.concat(@searchDirectories)

    # Remove blank entries
    directories = (directory.trim() for directory in directories when directory.trim() isnt "")

    if @todolist and directories.length isnt 0
        Todo.findInDirectories directories, (todos) =>
          for todo in todos
            todoView = new TodoView(todo)
            todoView.appendTo(@todolist)

  toggleVisibility: () ->
    if @view.isVisible()
      @view.hide()
      atom.config.set('organized.sidebarVisible', false)
      @emitter.emit 'did-hide', @
    else
      @view.show()
      atom.config.set('organized.sidebarVisible', true)
      @emitter.emit 'did-show', @
