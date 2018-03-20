slugify = require "underscore.string/slugify"

class DocView extends Backbone.View

  render: =>
    Coconut.database.get @docId
    .then (doc) =>
      @$el.html "
        <style>
          a{
            color:black;
            text-decoration: none;
          }
          .tag{
            display:block;
          }
        </style>
        <button class='mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect'>
          <a href='#wiki/edit/#{@docId}'>Edit</a></button>
        </button>
        <h1>#{doc.title}</h1>
        <h3>
          #{
            doc.tags?.map (tag) =>
              "
                <button class='mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect'>
                  <a class='tag' href='#wiki/doc/#{slugify(tag)}'>#{tag}</a>
                </button>
              "
            .join("") or ""
          }
        </h3>
        <h3 id='docsWithThisTag'>
          #{
            Coconut.database.query "docNamesByTag",
              key: doc.title
            .then (result) =>
              @$("#docsWithThisTag").html(
                result.rows.map (row) =>
                  "
                  <button class='mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect'>
                    <a style='display:block' href='#wiki/doc/#{row.id}'>#{row.value}</a>
                  </button>
                  "
                .join("")
              )
            ""
          }
        </h3>



          #{doc.content?.replace(/\n/g,"<br/>") or ""}
      "

module.exports = DocView
