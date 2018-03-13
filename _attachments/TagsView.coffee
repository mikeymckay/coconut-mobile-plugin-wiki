slugify = require "underscore.string/slugify"

class TagsView extends Backbone.View

  render: =>
    Coconut.database.query "docNamesByTag"
    .then (result) =>
      docsByTag = _(result.rows).groupBy (row) => row.key
      @$el.html "
        <h1>Tags</h1>
        #{
          _(docsByTag).map (rows, tag) =>
            "
            <h2>#{tag}</h2>
              #{
                rows.map (row) =>
                  "<a style='display:block' href='#wiki/doc/#{row.id}'>#{row.value}</a>"
                .join ""
              }
            "

        }
      "

module.exports = TagsView
