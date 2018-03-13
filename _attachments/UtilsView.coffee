class UtilsView extends Backbone.View
  el: '#content'

  events:
    "click .action": "action"

  action: (event) =>
    action = @$(event.target).attr("data-action")
    @[action]()

  render: =>
    @$el.html "
      #{
        _([
          "peopleDateToTerm"
          "peopleClassClean"
        ]).map (action) =>
          "
            <button class='action' data-action='#{action}' id='action-#{action}'>#{action}</button>
          "
        .join("")
      }
      <div id='utils-log'/>
    "

  log: (string) =>
    console.log string
    string = "<pre>#{JSON.stringify(string,null,2)}</pre>" if _(string).isObject()
    @$("#utils-log").append(string)

  recursivelyProcessAllDocs: (database, action, options = {limit:500, include_docs:true}) =>
    @log "."
    database.allDocs(options)
    .then (result) =>
      action(result).then =>
        if result and result.rows.length > 0
          options.startkey = result.rows[result.rows.length-1].id
          options.skip = 1
          @recursivelyProcessAllDocs(database,action,options)
        else
          @log "DONE"
          Promise.resolve()

  peopleClassClean: =>
    @counter = 0
    @recursivelyProcessAllDocs Coconut.peopleCloudDB, (result) =>
      updatedPeopleDocs = result.rows.map (row) =>
        person = row.doc
        changed = false
        _(
          [
            "verifications"
            "Performance and Attendance"
          ]
        ).each (property) =>
          _(person[property]).each (data, yearTerm) =>
            if _(data["Class"]).isNumber()
              console.log data["Class"]
              person[property][yearTerm]["Class"] = "Standard #{data["Class"]}"
              changed = true
              @counter += 1
        return if changed then person else null
      @log "Updated #{@counter} records"
      updatedPeopleDocs = _(updatedPeopleDocs).compact()
      Coconut.peopleCloudDB.bulkDocs(updatedPeopleDocs)

  peopleDateToTerm: =>
    @counter = 0
    @recursivelyProcessAllDocs Coconut.peopleCloudDB, (result) =>
      updatedPeopleDocs = result.rows.map (row) =>
        changed = false
        person = row.doc
        _(
          [
            "verifications"
            "Performance and Attendance"
          ]
        ).each (property) =>
          _(person[property]).each (ignore, date) =>
            switch date
              when "2017-09-15"
                @counter += 1
                person[property][date]["Timestamp"] = date
                person[property]["2017-T3"]= person[property][date]
                delete person[property][date]
                changed = true
              when "2017-07-19"
                @counter += 1
                person[property][date]["Timestamp"] = date
                person[property]["2017-T1"]= person[property][date]
                delete person[property][date]
                changed = true
              else
                unless date.match(/\d\d\d\d-T\d/)
                  console.log "Other value for date:"
                  console.log person
        return if changed then person else null

      @log "Updated #{@counter} records (some people have 2 records to be updated)"
      #@log updatedPeopleDocs
      updatedPeopleDocs = _(updatedPeopleDocs).compact()
      Coconut.peopleCloudDB.bulkDocs(updatedPeopleDocs)


module.exports = UtilsView
