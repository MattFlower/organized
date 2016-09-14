{View} = require 'atom-space-pen-views'
TextSearch = require 'rx-text-search'


module.exports =
class SearchView extends View
  searchDirectories: null
  searchSkipFiles: null
  view: null
  searchVisible: null
  includeProjectPaths: null
  skipFiles: null
  tags: new Set()

  @content: ->
    @div class: 'search-dialog', tabindex: -1, =>
      @div class: 'search-dialog-params', =>
        @div class: 'search-dialog-search-box-div', =>
          @input type: 'text'
        @hr
        @div class: 'tag-cloud', outlet: 'tagcloud'
      @hr
      @div class: 'search-results', outlet: 'results', =>

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

  constructor: ->
    super

  clearResults: ->
    @results.empty()

  destroy: ->
    @view.hide()
    @view.destroy()

  initialize: () ->
    @view ?= atom.workspace.addModalPanel(item: @, visible: false)

  refreshTags: () ->
    directories = []

    # Current open projects
    if @includeProjectPaths
      directories = directories.concat(atom.project.getPaths())

    # Search directories user has defined
    if @searchDirectories
      directories = directories.concat(@searchDirectories)

    # Remove blank entries
    directories = (directory.trim() for directory in directories when directory.trim() isnt "")

    skipFiles = atom.config.get('organized.searchSkipFiles')
    skipFiles = skipFiles.concat(['.git', '.atom'])
    skipFiles = (skipFile for skipFile in skipFiles when skipFile.trim() isnt '')

    @tags = new Set()

    if directories.length isnt 0
      @_refreshTagDirectories(directories, skipFiles)

  _refreshTagDirectories: (directories, skipFiles) ->
    # TextSearch.findAsPromise("(^|\s+):([A-Za-z0-9_@-]+:){1,}\s*$", "**/*.org", {cwd: directory, matchBase: true})
    console.log(directories)
    # if directories.pop
    #   path = directories.pop()
    # else
    #   path = directories
    # console.log("path: #{path}")

    if directory = directories.pop()
      TextSearch.findAsPromise("(^|\\s+):([A-Za-z0-9_@-]+:){1,}\\s*$", "**/*.org", {cwd: directory, matchBase: false})
        .then (results) =>
          for result in results
            skip = false
            for partial in skipFiles
              if result.file.indexOf(partial) > -1
                skip = true
                break
            if skip
              continue

            if match = /(?:^|\s+):([A-Za-z0-9_@-]+:){1,}\s*$/.exec(result.text)
              text = match[1][...-1]
              @tags.add(text)

          @_refreshTagDirectories(directories, skipFiles)
    else
      @tags.forEach (tag) =>
        console.log("Tag: #{tag}")
        @tagcloud.append('<span class="badge badge-info">' + tag + '</span>')

  show: () ->
    @view.show()
