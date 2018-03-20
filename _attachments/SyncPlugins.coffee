Sync::getFromCloud = (options) ->
  console.log "Getting from cloud"
  @fetch
    error: (error) =>
      @log "Unable to fetch Sync doc: #{JSON.stringify(error)}"
      options?.error?(error)
    success: =>
      Coconut.checkForInternet
        error: (error) =>
          @save
            last_send_error: true
          options?.error?(error)
          Coconut.noInternet()
        success: =>
          @fetch
            success: =>
              @replicateApplicationDocs
                error: (error) =>
                  $.couch.logout()
                  @log "ERROR updating application: #{JSON.stringify(error)}"
                  @save
                    last_get_success: false
                  options?.error?(error)
                success: =>
                  Coconut.database.replicate.from Coconut.cloudDB
                  .on "complete", =>
                    @save
                      last_get_success: true
                      last_get_time: new Date().getTime()
                    options?.success?()
                  .catch (error) -> console.error error

# Patch this to send user data
Sync::sendToCloud = (options) ->
  @fetch
    error: (error) =>
      @log "Unable to fetch Sync doc: #{JSON.stringify(error)}"
      options?.error?(error)
    success: =>
      Coconut.checkForInternet
        error: (error) =>
          @save
            last_send_error: true
          options?.error?(error)
          Coconut.noInternet()
        success: =>
          Coconut.database.replicate.to Coconut.cloudDB
          options?.success?()

