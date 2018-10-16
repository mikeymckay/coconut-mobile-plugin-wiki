titleize = require "underscore.string/titleize"
humanize = require "underscore.string/humanize"
Selectr = require 'mobius1-selectr'

class DocEditView extends Backbone.View

  events:
    "click button#save": "save"
    "click button#create": "create"
    "click button#rename": "rename"

  rename: =>
    newTitle = prompt("Enter new name", @doc.title)
    if newTitle
      @docId = slugify(newTitle)
      newDoc = _(@doc).clone()
      newDoc.title = newTitle
      newDoc._id = @docId
      delete newDoc._rev

      Coconut.database.remove(@doc).then =>
        @doc = newDoc
        @render()
        @save()


  save: =>
    @doc.tags = @selectr.getValue()
    @doc.content = @$("#content").val()
    @doc.updated or= []
    @doc.updated.push moment().format("YYYY-MM-DD")
    Coconut.database.put @doc
    .then =>
      Coconut.router.navigate "wiki/doc/#{@docId}", {trigger: true}

  create: =>
    @docId = slugify(@$("#title").val())
    @doc = {
      _id: @docId
      created: moment().format("YYYY-MM-DD")
      title: @$("#title").val()
      tags: []
    }
    Coconut.router.navigate "wiki/edit/#{@docId}", {trigger: false}
    @render()

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
          #{@selectrCss()}
        </style>
        <label>Title</label>
        <input id='title'/>
        <button id='create'>Create</button>
      "

    Coconut.database.get @docId
    .catch =>
      console.log "Creating new doc"
      Promise.resolve(@doc) # Use the doc created in @create()
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
          #{@selectrCss()}
        </style>
        <h1>#{@doc.title}<button id='rename'>Rename</button></h1>
        <label>Tags</label>
        <select id='tagChooser'></select>
        <textarea id='content'>#{@doc.content or ""}</textarea>
        <button id='save'>Save</button>
      "
      # TODO
      Coconut.database.query "docNamesByTag"
      .then (result) =>

        allTags = _(result.rows).chain().pluck("key").unique().map (tag) =>
          return if tag is ""
          {
            value: tag
            text: tag
          }
        .compact().value()

        @selectr = new Selectr "#tagChooser",
          data: allTags
          multiple: true
          taggable: true

        @selectr.setValue(@doc.tags)

  selectrCss: => """
    .selectr-container li,.selectr-option,.selectr-tag{list-style:none}.selectr-container{position:relative}.selectr-hidden{position:absolute;overflow:hidden;clip:rect(0,0,0,0);width:1px;height:1px;margin:-1px;padding:0;border:0}.selectr-visible{position:absolute;left:0;top:0;width:100%;height:100%;opacity:0;z-index:11}.selectr-desktop.multiple .selectr-visible{display:none}.selectr-desktop.multiple.native-open .selectr-visible{top:100%;min-height:200px!important;height:auto;opacity:1;display:block}.selectr-container.multiple.selectr-mobile .selectr-selected{z-index:0}.selectr-selected{position:relative;z-index:1;box-sizing:border-box;width:100%;padding:7px 28px 7px 14px;cursor:pointer;border:1px solid #999;border-radius:3px;background-color:#fff}.selectr-selected::before{position:absolute;top:50%;right:10px;width:0;height:0;content:'';-o-transform:rotate(0) translate3d(0,-50%,0);-ms-transform:rotate(0) translate3d(0,-50%,0);-moz-transform:rotate(0) translate3d(0,-50%,0);-webkit-transform:rotate(0) translate3d(0,-50%,0);transform:rotate(0) translate3d(0,-50%,0);border-width:4px 4px 0;border-style:solid;border-color:#6c7a86 transparent transparent}.selectr-container.native-open .selectr-selected::before,.selectr-container.open .selectr-selected::before{border-width:0 4px 4px;border-style:solid;border-color:transparent transparent #6c7a86}.selectr-label{display:none;overflow:hidden;width:100%;white-space:nowrap;text-overflow:ellipsis}.selectr-placeholder{color:#6c7a86}.selectr-tags{margin:0;padding:0;white-space:normal}.has-selected .selectr-tags{margin:0 0 -2px}.selectr-tag{position:relative;float:left;padding:2px 25px 2px 8px;margin:0 2px 2px 0;cursor:default;color:#fff;border:none;border-radius:10px;background:#acb7bf}.selectr-container.multiple.has-selected .selectr-selected{padding:5px 28px 5px 5px}.selectr-options-container{position:absolute;z-index:10000;top:calc(100% - 1px);left:0;display:none;box-sizing:border-box;width:100%;border-width:0 1px 1px;border-style:solid;border-color:transparent #999 #999;border-radius:0 0 3px 3px;background-color:#fff}.selectr-container.open .selectr-options-container{display:block}.selectr-input-container{position:relative;display:none}.selectr-clear,.selectr-input-clear,.selectr-tag-remove{position:absolute;top:50%;right:22px;width:20px;height:20px;padding:0;cursor:pointer;-o-transform:translate3d(0,-50%,0);-ms-transform:translate3d(0,-50%,0);-moz-transform:translate3d(0,-50%,0);-webkit-transform:translate3d(0,-50%,0);transform:translate3d(0,-50%,0);border:none;background-color:transparent;z-index:11}.selectr-clear,.selectr-input-clear{display:none}.selectr-container.has-selected .selectr-clear,.selectr-input-container.active,.selectr-input-container.active .selectr-clear,.selectr-input-container.active .selectr-input-clear{display:block}.selectr-selected .selectr-tag-remove{right:2px}.selectr-clear::after,.selectr-clear::before,.selectr-input-clear::after,.selectr-input-clear::before,.selectr-tag-remove::after,.selectr-tag-remove::before{position:absolute;top:5px;left:9px;width:2px;height:10px;content:' ';background-color:#6c7a86}.selectr-tag-remove::after,.selectr-tag-remove::before{top:4px;width:3px;height:12px;background-color:#fff}.selectr-clear:before,.selectr-input-clear::before,.selectr-tag-remove::before{-o-transform:rotate(45deg);-ms-transform:rotate(45deg);-moz-transform:rotate(45deg);-webkit-transform:rotate(45deg);transform:rotate(45deg)}.selectr-clear:after,.selectr-input-clear::after,.selectr-tag-remove::after{-o-transform:rotate(-45deg);-ms-transform:rotate(-45deg);-moz-transform:rotate(-45deg);-webkit-transform:rotate(-45deg);transform:rotate(-45deg)}.selectr-input{top:5px;left:5px;box-sizing:border-box;width:calc(100% - 30px);margin:10px 15px;padding:7px 30px 7px 9px;border:1px solid #999;border-radius:3px}.selectr-notice{display:none;box-sizing:border-box;width:100%;padding:8px 16px;border-top:1px solid #999;border-radius:0 0 3px 3px;background-color:#fff}.input-tag,.taggable .selectr-label{width:auto}.selectr-container.notice .selectr-notice{display:block}.selectr-container.notice .selectr-selected{border-radius:3px 3px 0 0}.selectr-options{position:relative;top:calc(100% + 2px);display:none;overflow-x:auto;overflow-y:scroll;max-height:200px;margin:0;padding:0}.selectr-container.notice .selectr-options-container,.selectr-container.open .selectr-input-container,.selectr-container.open .selectr-options{display:block}.selectr-option{position:relative;display:block;padding:5px 20px;cursor:pointer;font-weight:400}.has-selected .selectr-placeholder,.selectr-empty,.selectr-option.excluded{display:none}.selectr-options.optgroups>.selectr-option{padding-left:25px}.selectr-optgroup{font-weight:700;padding:0}.selectr-optgroup--label{font-weight:700;margin-top:10px;padding:5px 15px}.selectr-match{text-decoration:underline}.selectr-option.selected{background-color:#ddd}.selectr-option.active{color:#fff;background-color:#5897fb}.selectr-option.disabled{opacity:.4}.selectr-container.open .selectr-selected{border-color:#999 #999 transparent;border-radius:3px 3px 0 0}.selectr-container.open .selectr-selected::after{-o-transform:rotate(180deg) translate3d(0,50%,0);-ms-transform:rotate(180deg) translate3d(0,50%,0);-moz-transform:rotate(180deg) translate3d(0,50%,0);-webkit-transform:rotate(180deg) translate3d(0,50%,0);transform:rotate(180deg) translate3d(0,50%,0)}.selectr-disabled{opacity:.6}.has-selected .selectr-label{display:block}.taggable .selectr-selected{padding:4px 28px 4px 4px}.taggable .selectr-selected::after{display:table;content:" ";clear:both}.taggable .selectr-tags{float:left;display:block}.taggable .selectr-placeholder{display:none}.input-tag{float:left;min-width:90px}.selectr-tag-input{border:none;padding:3px 10px;width:100%;font-family:inherit;font-weight:inherit;font-size:inherit}.selectr-input-container.loading::after{position:absolute;top:50%;right:20px;width:20px;height:20px;content:'';-o-transform:translate3d(0,-50%,0);-ms-transform:translate3d(0,-50%,0);-moz-transform:translate3d(0,-50%,0);-webkit-transform:translate3d(0,-50%,0);transform:translate3d(0,-50%,0);-o-transform-origin:50% 0 0;-ms-transform-origin:50% 0 0;-moz-transform-origin:50% 0 0;-webkit-transform-origin:50% 0 0;transform-origin:50% 0 0;-moz-animation:.5s linear 0s normal forwards infinite running spin;-webkit-animation:.5s linear 0s normal forwards infinite running spin;animation:.5s linear 0s normal forwards infinite running spin;border-width:3px;border-style:solid;border-color:#aaa #ddd #ddd;border-radius:50%}@-webkit-keyframes spin{0%{-webkit-transform:rotate(0) translate3d(0,-50%,0);transform:rotate(0) translate3d(0,-50%,0)}100%{-webkit-transform:rotate(360deg) translate3d(0,-50%,0);transform:rotate(360deg) translate3d(0,-50%,0)}}@keyframes spin{0%{-webkit-transform:rotate(0) translate3d(0,-50%,0);transform:rotate(0) translate3d(0,-50%,0)}100%{-webkit-transform:rotate(360deg) translate3d(0,-50%,0);transform:rotate(360deg) translate3d(0,-50%,0)}}.selectr-container.open.inverted .selectr-selected{border-color:transparent #999 #999;border-radius:0 0 3px 3px}.selectr-container.inverted .selectr-options-container{border-width:1px 1px 0;border-color:#999 #999 transparent;border-radius:3px 3px 0 0;background-color:#fff;top:auto;bottom:calc(100% - 1px)}.selectr-container ::-webkit-input-placeholder{color:#6c7a86;opacity:1}.selectr-container ::-moz-placeholder{color:#6c7a86;opacity:1}.selectr-container :-ms-input-placeholder{color:#6c7a86;opacity:1}.selectr-container ::placeholder{color:#6c7a86;opacity:1}
  """



module.exports = DocEditView
