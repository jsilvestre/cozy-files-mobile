BaseView = require '../lib/base_view'

module.exports = class ConfigView extends BaseView

    template: require '../templates/config'

    events: ->
        'tap #configDone': 'configDone'
        'tap #redbtn': 'redBtn'
        'tap #contactSyncCheck': 'saveChanges'
        'tap #imageSyncCheck': 'saveChanges'
        'tap #wifiSyncCheck': 'saveChanges'

    getRenderData: ->
        config = app.replicator.config.toJSON()

        return _.extend {},
            config,
            lastSync: @formatDate config?.lastSync
            lastBackup: @formatDate config?.lastBackup
            firstRun: app.isFirstRun
            locale: app.locale

    # format a object as a readable date string
    # return t('never') if undefined
    formatDate: (date) ->
        unless date then return t 'never'
        else
            date = new Date(date) unless date instanceof Date
            return date.toDateString() + ' ' + date.toTimeString()

    # only happens after the first config (post install)
    configDone: ->
        app.router.navigate 'first-sync', trigger: true


    # confirm, destroy the DB, force refresh the page (show login form)
    redBtn: ->
        if confirm t 'confirm message'
            #@TODO delete device on remote ?
            app.replicator.destroyDB (err) =>
                return alert err.message if err
                $('#redbtn').text t 'done'
                window.location.reload(true);

    # save config changes in local pouchdb
    # prevent simultaneous changes by disabling checkboxes
    saveChanges: ->

        @$('#contactSyncCheck, #imageSyncCheck, #wifiSyncCheck').prop 'disabled', true
        app.replicator.config.save
            syncContacts: @$('#contactSyncCheck').is ':checked'
            syncImages: @$('#imageSyncCheck').is ':checked'
            syncOnWifi: @$('#wifiSyncCheck').is ':checked'
        , =>
            @$('#contactSyncCheck, #imageSyncCheck, #wifiSyncCheck').prop 'disabled', false
