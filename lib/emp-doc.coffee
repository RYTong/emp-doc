# EmpDocView = require './emp-doc-view'
{CompositeDisposable} = require 'atom'
default_index = 'doc/info_center/index.html'
inner_index = 'doc/inner_docs/index.html'
started_index = 'doc/get_started/index.html'
ert_index = 'doc/ert_develop/index.html'
ewp_index = 'doc/ewp_lib_example/index.html'
frontend_index = 'doc/frontend_dev_guide/index.html'
software_index = 'doc/software_specification/index.html'
xhtml_index = 'doc/xhtml_example/index.html'
backend_index = 'doc/backend_dev_guide/index.html'
compatible_index = 'doc/compatible_book/index.html'


path = require 'path'
fs = require 'fs'
open = require 'open'
EmpHtmlPreviewView = require './emp-doc-view'
emp = require './exports/emp'
html_view = null
tmp_relate_path = ''
# -------------------use for emp doc -------------------------
create_doc_view = (params) ->
  re_path = path.join __dirname, '../', tmp_relate_path
  console.log re_path
  console.log fs.existsSync re_path
  uri = emp.EMP_DOC_URI
  html_view = new EmpHtmlPreviewView({editorId:uri, doc_path:re_path})

open_doc_panel = (params)->
  tmp_relate_path = params
  # console.log "open_temp_wizard_panel"
  # atom.workspace.open(emp.EMP_DOC_URI)
  console.log 'EmpDoc was toggled!'

  # editor = atom.workspace.getActiveTextEditor()
  # return unless editor?

  uri = emp.EMP_DOC_URI

  previewPane = atom.workspace.paneForURI(uri)
  console.log previewPane
  if previewPane
    previewPane.destroyItem(previewPane.itemForUri(uri))
    return
  previousActivePane = atom.workspace.getActivePane()

  # atom.workspace.open re_path
  # tmp_uri =
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
      "emp-doc:show-doc": => open_doc_panel(default_index)
      "emp-doc:show-doc-brw": =>
        re_path = path.join __dirname, '../', default_index
        open(re_path)
      "emp-doc:show-inner": => open_doc_panel(inner_index)
      "emp-doc:show-inner-brw": =>
        re_path = path.join __dirname, '../', inner_index
        open(re_path)
      "emp-doc:show-started": => open_doc_panel(started_index)
      "emp-doc:show-started-brw": =>
        re_path = path.join __dirname, '../', started_index
        open(re_path)
      "emp-doc:show-ert": => open_doc_panel(ert_index)
      "emp-doc:show-ert-brw": =>
        re_path = path.join __dirname, '../', ert_index
        open(re_path)
      "emp-doc:show-ewp": => open_doc_panel(ewp_index)
      "emp-doc:show-ewp-brw": =>
        re_path = path.join __dirname, '../', ewp_index
        open(re_path)

      "emp-doc:show-frontend": => open_doc_panel(frontend_index)
      "emp-doc:show-frontend-brw": =>
        re_path = path.join __dirname, '../', frontend_index
        open(re_path)

      "emp-doc:show-xhtml": => open_doc_panel(xhtml_index)
      "emp-doc:show-xhtml-brw": =>
        re_path = path.join __dirname, '../', xhtml_index
        open(re_path)

      "emp-doc:show-backend": => open_doc_panel(backend_index)
      "emp-doc:show-backend-brw": =>
        re_path = path.join __dirname, '../', backend_index
        open(re_path)

      "emp-doc:show-compatible": => open_doc_panel(compatible_index)
      "emp-doc:show-compatible-brw": =>
        re_path = path.join __dirname, '../', compatible_index
        open(re_path)


  deactivate: ->
    # @modalPanel.destroy()
    @subscriptions.dispose()
    # @empDocView.destroy()

  serialize: ->
    # empDocViewState: @empDocView.serialize()
