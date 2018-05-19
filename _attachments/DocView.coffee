slugify = require "underscore.string/slugify"

class DocView extends Backbone.View

  render: =>
    Coconut.database.get @docId
    .then (doc) =>
      @$el.html "
        <style>
          a{
            color:ff4081;
            text-decoration: none;
          }
          .tag{
            display:block;
            margin-left:10px;
          }
          #tags, #docsWithThisTag{
            background-color: rgba(158,158,158,0.20);
            width: 300px;
            display: inline-grid;
          }
        </style>
        <button class='mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect'>
          <a href='#wiki/edit/#{@docId}'>Edit</a></button>
        </button>
        <h1>#{doc.title}</h1>
        <div id='allTags'>
          <div id='tags'>
            #{
              doc.tags?.map (tag) =>
                "
                <a class='tag' href='#wiki/doc/#{slugify(tag)}'>#{tag}</a>
                "
              .join("") or ""
            }
          </div>
          <div id='docsWithThisTag'>
            #{
              Coconut.database.query "docNamesByTag",
                key: doc.title
              .then (result) =>
                @$("#docsWithThisTag").html(
                  result.rows.map (row) =>
                    "
                    <a style='display:block' href='#wiki/doc/#{row.id}'>#{row.value}</a>
                    "
                  .join("")
                )
              ""
            }
          </div>
        </div>



          #{doc.content?.replace(/\n/g,"<br/>") or ""}
      "

module.exports = DocView
