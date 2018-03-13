Sync::getFromCloud = (options) ->
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
                  Sync.getRelevantPersonData()
                  .then =>
                    Coconut.schoolsDB.replicate.from Coconut.schoolsCloudDB
                  .then =>
                    Sync.syncAllEnrollmentsForCurrentSchools()
                  .then =>
                    Sync.syncAllSpotchecksForCurrentSchools()
                  .then =>
                    @save
                      last_get_success: true
                      last_get_time: new Date().getTime()
                    options?.success?()
                  .catch (error) -> console.error error

Sync.syncAllEnrollmentsForCurrentSchools = =>
  schoolIds = Coconut.currentUser.schools?.map( (id) -> parseInt(id.replace(/school-/,"")) ) or []
  enrollmentIdsToSync = []
  Promise.all( schoolIds.map (schoolId) ->
    Coconut.enrollmentsCloudDB.allDocs
      startkey: "enrollment-school-#{schoolId}"
      endkey: "enrollment-school-#{schoolId}\uf000"
      include_docs: false
    .then (result) ->
      enrollmentIdsToSync.push.apply(enrollmentIdsToSync, _(result.rows).pluck("id"))

  ).then ->
    console.log "Getting enrollments: #{enrollmentIdsToSync}"
    Coconut.enrollmentsDB.replicate.from Coconut.enrollmentsCloudDB,
      doc_ids: enrollmentIdsToSync

Sync.syncAllSpotchecksForCurrentSchools = =>
  schoolIds = Coconut.currentUser.schools?.map( (id) -> parseInt(id.replace(/school-/,"")) ) or []
  spotcheckIdsToSync = []
  Promise.all( schoolIds.map (schoolId) ->
    Coconut.spotchecksCloudDB.allDocs
      startkey: "spotcheck-enrollment-school-#{schoolId}"
      endkey: "spotcheck-enrollment-school-#{schoolId}\uf000"
      include_docs: false
    .then (result) ->
      spotcheckIdsToSync.push.apply(spotcheckIdsToSync, _(result.rows).pluck("id"))

  ).then ->
    console.log "Getting spotchecks: #{spotcheckIdsToSync}"
    Coconut.spotchecksDB.replicate.from Coconut.spotchecksCloudDB,
      doc_ids: spotcheckIdsToSync

Sync.getRelevantPersonData = (options) ->
  if $("#message-bar").length is 0
    $("nav.mdl-navigation").after("<span id='message-bar'></span>")
  $("#message-bar").html("Getting list of learners...")

  schoolIds = Coconut.currentUser.schools?.map( (id) -> parseInt(id.replace(/school-/,"")) ) or []
  console.log "Looking for learners from schools with IDs: #{schoolIds}"
  Coconut.peopleCloudDB.query "peopleBySchool", # People from all of the current user's schools
    keys: schoolIds
    include_docs: false
  .catch (error) ->
    console.error "Error querying peopleBySchoolAndClass with keys: #{schoolIds}"
  .then (result) ->
    peopleIdsFromRelevantsSchools = _(result.rows).pluck("id")
    console.log "People from schools #{schoolIds}: #{peopleIdsFromRelevantsSchools.length}"
    Coconut.peopleDB.allDocs().then (result) -> # All of the people currently on the tablet
      peopleIdsFromRelevantsSchools = peopleIdsFromRelevantsSchools.concat(_(result.rows).pluck("id"))
      console.log "Including people currently on tablet: #{peopleIdsFromRelevantsSchools.length}"

      console.log Coconut.currentUser.schools
      Coconut.schoolsCloudDB.allDocs
        keys: Coconut.currentUser.schools or []
        include_docs: true
      .then (result) ->
        console.log result

        # If school is secondary then get all primary school students in region
        region = null
        secondarySchools = _(result.rows).chain().map (row) ->
          if row.doc["School Level"] is "Secondary"
            row.doc["KEEP Assigned Code"]
            region = row.doc.Region
          else
            null
        .compact().value()

        console.log "Secondary schools: #{secondarySchools}"

        year = (new Date()).getFullYear()-1
        className = "Standard 8"
  
        # If no secondarySchools the region will be null
        Coconut.peopleCloudDB.query "peopleByYearRegionClass",
          key: [year,region,className]
        .then (result) ->
          peopleIdsFromRelevantsSchools = peopleIdsFromRelevantsSchools.concat(_(result.rows).pluck("id"))
          peopleIdsFromRelevantsSchools = _(peopleIdsFromRelevantsSchools).unique()

          console.log "People including secondarySchool requirements: #{peopleIdsFromRelevantsSchools.length}"

          console.log "Getting #{peopleIdsFromRelevantsSchools.length} people"
          $("#message-bar").html("Updating details for #{peopleIdsFromRelevantsSchools.length} learners...")
          Coconut.peopleDB.replicate.from Coconut.peopleCloudDB,
            doc_ids: peopleIdsFromRelevantsSchools
          .on "change", (change) ->
            $("#message-bar").html("#{Math.floor(100*(change.docs_written/peopleIdsFromRelevantsSchools.length))}% Complete")
          .on "complete", ->
            $("#message-bar").html("Complete. #{peopleIdsFromRelevantsSchools.length} learners updated.")
            _.delay ->
              $("#message-bar").html("")
            ,10000
            Promise.resolve()
          .on "error", (error) ->
            console.error error
          .then ->


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

          # Replicate all of the databases to the cloud
          # See Plugin.coffee to see where these are defined
          #
          Promise.all(Coconut.databases.map (database) ->
            Coconut["#{database}DB"].replicate.to Coconut["#{database}CloudDB"],
              timeout: 60000
              batch_size: 20
            .on 'change', (info) =>
              console.log info
            .on 'complete', (info) =>
              console.log info
          ).then =>
            Coconut.database.replicate.to Coconut.cloudDB,
              timeout: 60000
              batch_size: 20
            .on 'change', (info) =>
              console.log info
            .on 'complete', (info) =>
              console.log info

              @log "Success! Send data finished: created, updated or deleted #{info.docs_written} results on the server."
              @save
                last_send_result: info
                last_send_error: false
                last_send_time: new Date().getTime()
              options.success()
            .on 'error', (error) ->
              console.error error
              options.error(error)
