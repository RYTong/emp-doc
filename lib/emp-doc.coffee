# EmpDocView = require './emp-doc-view'
{CompositeDisposable} = require 'atom'
default_index = 'doc/info_center/index.html'
path = require 'path'
fs = require 'fs'
EmpHtmlPreviewView = require './emp-doc-view'
emp = require './exports/emp'
html_view = null
# -------------------use for emp doc -------------------------
create_doc_view = (params) ->
  re_path = path.join __dirname, '../', default_index
  console.log re_path
  console.log fs.existsSync re_path
  uri = emp.EMP_DOC_URI
  html_view = new EmpHtmlPreviewView({editorId:uri, doc_path:re_path})

open_doc_panel = (params)->
  # console.log "open_temp_wizard_panel"
  # atom.workspace.open(emp.EMP_DOC_URI)
  console.log 'EmpDoc was toggled!'

  editor = atom.workspace.getActiveTextEditor()
  return unless editor?
  uri = "html-preview://editor/#{editor.id}"
  console.log uri
  uri = emp.EMP_DOC_URI

  previewPane = atom.workspace.paneForURI(uri)
  console.log previewPane
  if previewPane
    previewPane.destroyItem(previewPane.itemForUri(uri))
    return
  previousActivePane = atom.workspace.getActivePane()


  # atom.workspace.open re_path
  atom.workspace.open(uri, searchAllPanes: true).done (html_view) ->
    if html_view instanceof EmpHtmlPreviewView
      console.log "render"
      html_view.renderHTML()
      previousActivePane.activate()
  # empTmpManagementView.add_new_panel()

snippets_deserializer =
  name: emp.EMP_DOC_VIEW
  version: 1
  deserialize: (state) ->
    console.log "emp doc view deserialize"
    create_doc_view(state) if state.constructor is Object

atom.deserializers.add(snippets_deserializer)

module.exports = EmpDoc =
  empDocView: null
  modalPanel: null
  html_view: null
  subscriptions: null

  activate: (state) ->
    # @empDocView = new EmpDocView(state.empDocViewState)
    # @modalPanel = atom.workspace.addModalPanel(item: @empDocView.getElement(), visible: false)
    atom.workspace.addOpener (uri) ->
      if uri is emp.EMP_DOC_URI
        create_doc_view({uri})

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    # @subscriptions.add atom.commands.add 'atom-workspace', 'emp-doc:show-doc': => @toggle()
    @subscriptions.add atom.commands.add "atom-workspace",
      "emp-doc:show-doc": => open_doc_panel(emp.EMP_DOC_URI)

  deactivate: ->
    # @modalPanel.destroy()
    @subscriptions.dispose()
    # @empDocView.destroy()

  serialize: ->
    # empDocViewState: @empDocView.serialize()
