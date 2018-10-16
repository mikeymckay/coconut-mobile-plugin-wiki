slugify = require "underscore.string/slugify"

class TagsView extends Backbone.View

  render: =>
    Coconut.database.query "docNamesByTag"
    .then (result) =>
      docsByTag = _(result.rows).groupBy (row) => row.key
      @$el.html "
        <h1>Documents Grouped By Tag</h1>
        #{
          _(docsByTag).map (rows, tag) =>
            "
            <h2><a href='#wiki/doc/#{slugify(tag)}'>#{tag}</a></h2>
              #{
                rows.map (row) =>
                  "<a style='display:block' href='#wiki/doc/#{row.id}'>#{row.value}</a>"
                .join ""
              }
            "

        }
      "

module.exports = TagsView
