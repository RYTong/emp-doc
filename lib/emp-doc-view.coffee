{CompositeDisposable, Disposable} = require 'atom'
{$, $$$, ScrollView}  = require 'atom-space-pen-views'
_                     = require 'underscore-plus'
emp = require './exports/emp'
path = require 'path'
fs   = require 'fs'
module.exports =
class EmpHtmlPreviewView extends ScrollView
  atom.deserializers.add(this)

  editorSub           : null
  onDidChangeTitle    : -> new Disposable()
  onDidChangeModified : -> new Disposable()

  @deserialize: (state) ->
    new EmpHtmlPreviewView(state)

  @content: ->
    @div class: 'emp-doc native-key-bindings', tabindex: -1

  constructor: ({@editorId, @doc_path}) ->
    super

    if @editorId?
      @resolveEditor(@editorId)
    else
      if atom.workspace?
        @subscribeToFilePath(@doc_path)
      else
        # @subscribe atom.packages.once 'activated', =>
        atom.packages.onDidActivatePackage =>
          @subscribeToFilePath(@doc_path)

  serialize: ->
    deserializer : 'EmpHtmlPreviewView'
    filePath     : @getPath()
    editorId     : @editorId

  destroy: ->
    # @unsubscribe()
    # @editorSub.dispose()

  subscribeToFilePath: (filePath) ->
    @trigger 'title-changed'
    # @handleEvents()
    @renderHTML()

  resolveEditor: (editorId) ->
    resolve = =>
      @editor = @editorForId(editorId)

      if @editor?
        @trigger 'title-changed' if @editor?
        # @handleEvents()
      else
        # The editor this preview was created for has been closed so close
        # this preview since a preview cannot be rendered without an editor
        atom.workspace?.paneForItem(this)?.destroyItem(this)

    if atom.workspace?
      resolve()
    else
      # @subscribe atom.packages.once 'activated', =>
      atom.packages.onDidActivatePackage =>
        resolve()
        @renderHTML()

  editorForId: (editorId) ->
    for editor in atom.workspace.getTextEditors()
      return editor if editor.id?.toString() is editorId.toString()
    null

  handleEvents: =>

    changeHandler = =>
      @renderHTML()
      pane = atom.workspace.paneForURI(@getURI())
      if pane? and pane isnt atom.workspace.getActivePane()
        pane.activateItem(this)

    @editorSub = new CompositeDisposable

    if @editor?
      if not atom.config.get("atom-html-preview.triggerOnSave")
        @editorSub.add @editor.onDidChange _.debounce(changeHandler, 700)
      else
        @editorSub.add @editor.onDidSave changeHandler
      @editorSub.add @editor.onDidChangePath => @trigger 'title-changed'

  renderHTML: ->
    @showLoading()
    # if @editor?
    console.log @doc_path
    if fs.existsSync @doc_path
      doc_text = fs.readFileSync @doc_path, 'utf-8'
      @renderHTMLCode(doc_text)

  renderHTMLCode: (text) ->

    iframe = document.createElement("iframe")
    # Fix from @kwaak (https://github.com/webBoxio/atom-html-preview/issues/1/#issuecomment-49639162)
    # Allows for the use of relative resources (scripts, styles)
    iframe.setAttribute("sandbox", "allow-scripts allow-same-origin")
    iframe.src = @getPath()
    @html $ iframe
    # @trigger('atom-html-preview:html-changed')
    # atom.commands.dispatch 'atom-html-preview', 'html-changed'

  getTitle: ->
    "EMP Doc"

  getURI: ->
    emp.EMP_DOC_URI

  getPath: ->
    @doc_path

  showError: (result) ->
    failureMessage = result?.message

    @html $$$ ->
      @h2 'Previewing HTML Failed'
      @h3 failureMessage if failureMessage?

  showLoading: ->
    @html $$$ ->
      @div class: 'atom-html-spinner', 'Loading HTML Preview\u2026'
