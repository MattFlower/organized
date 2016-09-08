{Disposable} = require 'atom'
deps = require('atom-package-deps')

#
# Create a toolbar based on the tool-bar package.  We don't install the
# tool-bar package automatically, so how much this is used is a guess.
#
# Eventually, I'll make a menu item to toggle the toolbar manually, which
# will ask the user if they want to install the tool-bar plugin.
#
class OrganizedToolbar
  toolBar: null
  toolBarHasItems: false
  enabled: true
  sidebar: null
  sidebarToggle: null

  constructor: () ->
    # Make sure toolbar is only active when organized is active.
    atom.workspace.onDidChangeActivePaneItem (item) =>
      if item?.getGrammar?()?.name is 'Organized' and @enabled
        @addToolbar()
      else if @toolBar
        @removeToolbarButtons()

  activate: (subscriptions) ->
    subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:toggleToolbar': (event) => @toggleToolbar()}))
    subscriptions.add atom.config.observe 'organized.enableToolbarSupport', (newValue) => @setEnabled(newValue)

  # If the user doesn't currently have the toolbar up, this will add the appropriate buttons.
  # This is necessary because the tool-bar package is global -- if you don't dynamically add
  # and remove the buttons, they'll stay around even when organized isn't loaded.
  addToolbar: () ->
    if not atom.packages.getLoadedPackage('tool-bar')
      # This has a promise that will call addToolbar if it can be installed correctly, so we'll return for now.
      @installToolbarPlugin()
      return

    if @toolBarHasItems or not @toolBar or not @enabled
      return

    @toolBar.addButton
      icon: 'indent'
      iconset: 'fa'
      callback: 'organized:indent'
      tooltip: 'Indent'

    @toolBar.addButton
      icon: 'outdent'
      iconset: 'fa'
      callback: 'organized:unindent'
      tooltip: 'Unindent'

    @toolBar.addSpacer()

    @toolBar.addButton
      icon: 'hashtag'
      iconset: 'fa'
      callback: 'organized:toggleHeading'
      tooltip: 'Headings'

    @toolBar.addButton
      icon: 'check-square-o'
      iconset: 'fa'
      callback: 'organized:toggleTodo'
      tooltip: 'Toggle Todo'

    @toolBar.addButton
      icon: 'bold',
      iconset: 'fa',
      callback: 'organized:toggleBold',
      tooltip: 'Bold'

    @toolBar.addButton
      icon: 'underline',
      iconset: 'fa',
      callback: 'organized:toggleUnderline',
      tooltip: 'Underline'

    @toolBar.addSpacer()

    @toolBar.addButton
      icon: 'link',
      iconset: 'fa',
      callback: 'organized:makeLink',
      tooltip: 'Link'

    @toolBar.addSpacer()

    @toolBar.addButton
      icon: 'table',
      iconset: 'fa',
      callback: 'organized:createTable'
      tooltip: 'Create Table'

    @toolBar.addSpacer()

    @toolBar.addButton
      icon: 'code',
      iconset: 'fa',
      callback: 'organized:makeCodeBlock'
      tooltip: 'Create Code Block'

    @toolBar.addButton
      icon: 'play'
      iconset: 'fa',
      callback: 'organized:executeCodeBlock'
      tooltip: 'Execute Code Block'

    @toolBar.addButton
      icon: 'terminal'
      iconset: 'fa'
      callback: 'organized:makeResultBlock'
      tooltip: 'Create Code Execution Result Block'

    sidebarIcon = if @sidebar?.enabled then 'toggle-on' else 'toggle-off'
    sidebarTooltip = if @sidebar?.enabled then 'Hide Sidebar' else 'Show Sidebar'
    @sidebarToggle = @toolBar.addButton
      icon: 'toggle-on'
      iconset: 'fa'
      callback: 'organized:toggleSidebar'
      tooltip: sidebarTooltip

    @toolBarHasItems = true

  consumeToolBar: (toolBar) ->
    @toolBar = toolBar('organized');
    if editor = atom.workspace.getActiveTextEditor()
      if editor.getGrammar().name is 'Organized'
        @addToolbar()
        new Disposable =>
          @removeToolbar()
          toolBar = null

  deactivate: () ->
    @removeToolbar()

  removeToolbar: (event) ->
    if @toolBar
      @toolBar.removeItems();
      @toolBarHasItems = false

  removeToolbarButtons: (event) ->
    if @toolBar
      @toolBar.removeItems();
      @toolBarHasItems = false

  setEnabled: (enabled) ->
    @enabled = enabled

    if @enabled
      @addToolbar()
    else
      @removeToolbar()


  installToolbarPlugin: () ->
    atom.confirm
      message: "tool-bar package is not installed, it is required to see the organized toolbar.  Would you like to install it?"
      buttons:
        Yes: =>
          deps.install()
            .then () =>
              atom.config.set('organized.enableToolbarSupport', true)
              @addToolbar
            .catch (e) =>
              atom.notifications.addError("Unable to turn on organizedToolbar - encountered error while installing tool-bar package")
              atom.notifications.addError(e)
        No: =>
          atom.notifications.addWarning("Unable to turn on organizedToolbar - tool-bar package is not installed")
    return

  setSidebar: (sidebar)  ->
    @sidebar = sidebar
    @sidebar.onDidHide @sidebarHidden
    @sidebar.onDidShow @sidebarShown

  sidebarHidden: (sidebar) =>
    if @sidebarToggle
      @sidebarToggle.element.classList.remove('fa-toggle-on')
      @sidebarToggle.element.classList.add('fa-toggle-off')
      @sidebarToggle.tooltip = "Show Sidebar"

  sidebarShown: (sidebar) =>
    if @sidebarToggle?.element
      @sidebarToggle.element.classList.remove('fa-toggle-off')
      @sidebarToggle.element.classList.add('fa-toggle-on')
      @sidebarToggle.tooltip = "Hide Sidebar"

  # This is a little bit misleading.  It's here so we guide the user to install the tool-bar
  # plugin.
  toggleToolbar: () ->
    if atom.workspace.getActiveTextEditor().getGrammar().name isnt 'Organized'
      atom.notifications.addInfo("Organized toolbar won't appear on this page because this isn't an Organized file.")
      atom.config.set('organized.enableToolbarSupport', true)
    else
      atom.config.set('organized.enableToolbarSupport', not @enabled)

module.exports = OrganizedToolbar
