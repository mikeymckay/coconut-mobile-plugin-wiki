# MenuView Plugins

MenuView::questionLinks = (option) ->
  $("#drawer_question_sets").html MenuView.links().join("")

MenuView.links = ->
    _([
      "##{Coconut.databaseName}/tags,view-dashboard,Tags"
    ]).map (linkData) ->
      [url,icon,linktext] = linkData.split(",")
      "<a class='topmenu mdl-navigation__link' href='#{url}' id='#{linktext.replace(/\s+/g, '-').toLowerCase()}'><i class='mdl-color-text--blue-grey-400 mdi mdi-#{icon}'></i> #{linktext}</a>"

MenuView::generalMenu = ->
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

