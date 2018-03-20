#Router Plugins

TagsView = require './TagsView'
UtilsView = require './UtilsView'
DocView = require './DocView'
DocEditView = require './DocEditView'

Router::default = =>
  Backbone.history.loadUrl()
  Coconut.router.navigate "##{Coconut.databaseName}/doc/home",trigger: true

Coconut.router._bindRoutes()

Coconut.router.route ":database/tags", ->
  Coconut.tagsView ?= new TagsView()
  Coconut.tagsView.setElement $("#content")
  Coconut.tagsView.render()

Coconut.router.route ":database/doc/:docId", (docId) ->
  Coconut.docView ?= new DocView()
  Coconut.docView.docId = docId
  Coconut.docView.setElement $("#content")
  Coconut.docView.render()

Coconut.router.route ":database/edit/:docId", (docId) ->
  Coconut.docEditView ?= new DocEditView()
  Coconut.docEditView.docId = docId
  Coconut.docEditView.setElement $("#content")
  Coconut.docEditView.render()

Coconut.router.route ":database/new", (docId) ->
  Coconut.docEditView ?= new DocEditView()
  Coconut.docEditView.setElement $("#content")
  Coconut.docEditView.render()
