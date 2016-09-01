{Disposable} = require 'atom'
# deps = require('atom-package-deps')

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

  constructor: () ->
    # Make sure toolbar is only active when organized is active.
    atom.workspace.onDidChangeActivePaneItem (item) =>
      if item and item.getGrammar and item.getGrammar().name is 'Organized' and @toolBar
        @addToolbar()
      else if @toolBar
        @removeToolbarButtons()

  activate: (subscriptions) ->
    subscriptions.add(atom.commands.add('atom-text-editor', { 'organized:toggleToolbar': (event) => @organizedToolbar.toggleToolbar()}))
    subscriptions.add atom.config.observe 'organized.enableToolbarSupport', (newValue) => @setEnabled(newValue)

  # If the user doesn't currently have the toolbar up, this will add the appropriate buttons.
  # This is necessary because the tool-bar package is global -- if you don't dynamically add
  # and remove the buttons, they'll stay around even when organized isn't loaded.
  addToolbar: () ->
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

    @toolBarHasItems = true

  consumeToolBar: (toolBar) ->
    @toolBar = toolBar('organized');
    if editor = atom.workspace.getActiveTextEditor()
      if editor.getGrammar().name is 'Organized'
        @addToolbar()
        new Disposable => @removeToolbar()

  deactivate: () ->
    @removeToolbar()

  removeToolbar: (event) ->
    if @toolBar
      @toolBar.removeItems();
      @toolBar = null;
      @toolBarHasItems = false

  removeToolbarButtons: (event) ->
    if @toolBar
      @toolBar.removeItems();
      @toolBarHasItems = false

  setEnabled: (enabled) ->
    if @enabled and not enabled
      @removeToolbar()

    @enabled = enabled

  # This is a little bit misleading.  It's here so we guide the user to install the tool-bar
  # plugin.
  toggleToolbar: () ->
    if not atom.packages.getLoadedPackage('tool-bar')
      atom.notifications.addWarning("tool-bar is not installed.  Please install it to see a tool-bar.")
      atom.config.set('organized.enableToolbarSupport', true)
      # deps.install()
      #   .then () =>
      #     @addToolbar
      #   .catch (e) =>
      #     console.log(e)
      return

    if not atom.config.get('organized.enableToolbarSupport') or not @enabled
      atom.config.set('organized.enableToolbarSupport', true)
      @addToolbar
    else
      atom.config.set('organized.enableToolbarSupport', false)
      @removeToolbarButtons

module.exports = OrganizedToolbar
