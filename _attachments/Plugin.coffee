PouchDB.plugin(require('pouchdb-upsert'))

require './DesignDocs'
require './SyncPlugins'
require './MenuViewPlugins'

$.getScript("datatables.min.js")
$("head").append "<link rel='stylesheet' type='text/css' href='datatables.min.css'/>"

# Adds a delay method to chain in delay to promises
Promise::delay = (t) ->
  @then (v) ->
    new Promise( (resolve) ->
      setTimeout(resolve.bind(null, v), t)
    )

# Leave the header mostly empty
HeaderView::questionTabs = (options) ->

onStartup = ->
  try
    require './RouterPlugins'

    # Make sure at least one sync has happened
    # This ensures that plugin changes to sync have been applied
    Coconut.database.get "_local/last_sync"
    .catch (error) ->
      console.log error
      if error.message is "missing"
        console.log "NEED TO SYNC"
        Coconut.router.sendAndGet()
      else
        console.error error

    DesignDocs.load()

  catch error
    console.error error

global.StartPlugins = [] unless StartPlugins?
StartPlugins.push onStartup

module.exports = Plugin
