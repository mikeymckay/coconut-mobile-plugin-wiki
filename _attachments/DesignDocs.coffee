global.DesignDocs =
  load: ->

    # Note that the same function in master is hard coded to Coconut.database
    # Also, I refactored that one and everything broke
    addOrUpdateDesignDoc = (database,designDoc) ->
      name = designDoc._id.replace(/^_design\//,"")

      database.get "_design/#{name}", (error,result) ->
        # Check if it already exists and is the same
        if result?.views?[name]?.map is designDoc.views[name].map
          Promise.resolve()
        else
          console.log "Updating design doc for #{name}"
          if result? and result._rev
            designDoc._rev = result._rev
          database.put(designDoc)
          .catch (error) ->
            console.log "Error. Current Result:"
            console.log result

            console.log error
            console.log "^^^^^ Error updating designDoc for #{name}:"
            console.log designDoc

    docNamesByTag = Utils.createDesignDoc("docNamesByTag", (doc) ->
      if doc.tags
        for tag in doc.tags
          emit(tag, doc.title)
      emit(doc.title, doc.title)
    )

    addOrUpdateDesignDoc(Coconut.database, docNamesByTag)
