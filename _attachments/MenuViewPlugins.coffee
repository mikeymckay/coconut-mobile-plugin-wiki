# MenuView Plugins
#
SweetAlert = require 'sweetalert2'
titleize = require "underscore.string/titleize"
humanize = require "underscore.string/humanize"

MenuView::questionLinks = (option) ->
  $("#drawer_question_sets").html MenuView.links().join("")

MenuView.links = ->
    _([
      "##{Coconut.databaseName}/tags,view-dashboard,Tags"
    ]).map (linkData) ->
      [url,icon,linktext] = linkData.split(",")
      "<a class='topmenu mdl-navigation__link' href='#{url}' id='#{linktext.replace(/\s+/g, '-').toLowerCase()}'><i class='mdl-color-text--blue-grey-400 mdi mdi-#{icon}'></i> #{linktext}</a>"

MenuView::generalMenu = ->

  $("#layout-title").html "Claudia's Collections"

  $("#drawer_general_menu").html (
    _([
      "##{Coconut.databaseName}/sync,sync,Sync data"
      "##{Coconut.databaseName}/manage,database,Manage"
      "##{Coconut.databaseName}/logout,logout,Logout"
    ]).map (linkData) ->
      [url,icon,linktext] = linkData.split(",")
      "<a class='mdl-navigation__link' href='#{url}' id='#{linktext.toLowerCase()}'><i class='mdl-color-text--blue-grey-400 mdi mdi-#{icon}'></i>#{linktext}</a>"
    .join("")
  )

  $("nav.mdl-navigation").html "
    <a href='#wiki/new' class='mdl-navigation__link top_links'>
      <span>
        New
      </span>
    </a>

    <a href='#wiki/tags' class='mdl-navigation__link top_links'>
      <span>
        Doc List
      </span>
    </a>

    <div style='margin-left:40px;vertical-align:middle'>
      <input id='search'/>
      <button id='searchButton' class='mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect'>Search</button>
      <div id='searchResults' style='position:absolute; background-color:white; color:black;'>
      </div>
    </div>
  "
  

  $("#search").keyup =>
    Coconut.database.allDocs
      startkey: $("#search").val().toLowerCase()
      limit: 10
      include_docs: true
    .then (result) =>
      @$("#searchResults").html "
        <ul>
          #{
            _(result.rows).map (row) =>
              "<li><a style='color:black' href='#wiki/doc/#{row.id}'>#{row.doc.title}</a></li>"
            .join("")
          }
        </ul>
      "

  $("#searchButton").click =>
    _.delay =>
      Coconut.database.search
        query: $("#search").val()
        fields: ['title', 'tags', 'content']
      .then (res) =>
        @$("#searchResults").html ""
        SweetAlert(
          showCancelButton: true
          html: _(res.rows).map (row) =>
            "
            <a href='#wiki/doc/#{row.id}'>
              #{humanize(titleize(row.id))}
            </a>
            "
          .join("<br/>")
        )
    , 2000
