titleize = require "underscore.string/titleize"

class DocEditView extends Backbone.View

  events:
    "click button#save": "save"
    "click button#create": "create"

  save: =>
    @doc.title = @$("#title").val()
    @doc.tags = @$("#tags").val().split(/\n/)
    @doc.content = @$("#content").val()
    Coconut.database.put @doc
    .then =>
      Coconut.router.navigate "wiki/doc/#{@docId}", {trigger: true}

  create: =>
    Coconut.router.navigate "wiki/edit/#{slugify @$("#title").val()}", {trigger: true}

  render: =>
    unless @docId
      return @$el.html "
        <style>
          #title{
            display:block;
            font-size:2em;
            display:block;
          }
          #create{
            font-size: 2em;
          }
        </style>
        <label>Title</label>
        <input id='title'/>
        <button id='create'>Create</button>
      "

    Coconut.database.get @docId
    .catch =>
      console.log "Creating new doc"
      Promise.resolve
        _id: @docId
        tags: []
    .then (@doc) =>
      @$el.html "
        <style>
          #title{
            display:block;
            font-size:2em;
            display:block;
          }
          #tags{
            display:block;
            width: 65%;
          }
          #content{
            display:block;
            width: 95%;
            height: 720px;
          }
          #save{
            font-size: 2em;
          }
        </style>
        <label>Title</label>
        <input id='title' value='#{@doc.title or titleize(@docId)}'/>
        <label>Tags (one on each line)</label>
        <textarea id='tags'>#{@doc?.tags.join("\n") or ""}</textarea>
        <textarea id='content'>#{@doc.content or ""}</textarea>
        <button id='save'>Save</button>
      "

module.exports = DocEditView
