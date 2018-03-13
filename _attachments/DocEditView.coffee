class DocEditView extends Backbone.View

  events:
    "click button#save": "save"

  save: =>
    @doc.title = @$("#title").val()
    @doc.tags = @$("#tags").val().split(/\n/)
    @doc.content = @$("#content").val()
    Coconut.database.put @doc
    .then =>
      Coconut.router.navigate "wiki/doc/#{@docId}", {trigger: true}


  render: =>
    Coconut.database.get @docId
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
        <input id='title' value='#{@doc.title}'/>
        <label>Tags (one on each line)</label>
        <textarea id='tags'>#{@doc.tags.join("\n")}</textarea>
        <textarea id='content'>#{@doc.content}</textarea>
        <button id='save'>Save</button>
      "

module.exports = DocEditView
