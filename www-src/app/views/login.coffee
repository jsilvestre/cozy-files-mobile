BaseView = require '../lib/base_view'

module.exports = class LoginView extends BaseView

    className: 'list'
    template: require '../templates/login'

    events: ->
        'click #btn-save': 'doSave'

    getRenderData: ->
        defaultValue = app.loginConfig  or cozyURL: '', password: ''
        return {defaultValue}

    doSave: ->
        return null if @saving
        @saving = $('#btn-save').text()
        @error.remove() if @error

        url = @$('#input-url').val()
        pass = @$('#input-pass').val()

        # check all fields filled
        unless url and pass
            return @displayError 'all fields are required'

        # keep only the hostname
        if url[0..3] is 'http'
            url = url.replace('https://', '').replace('http://', '')
            @$('#input-url').val url

        # remove trailing slash
        if url[url.length-1] is '/'
            @$('#input-url').val url = url[..-2]

        config =
            cozyURL: url
            password: pass

        $('#btn-save').text t 'authenticating...'
        app.replicator.checkCredentials config, (error) =>

            if error?
                @displayError error
            else
                app.loginConfig = config
                console.log 'check credentials done'
                app.router.navigate 'device-name-picker', trigger: true

    displayError: (text, field) ->
        $('#btn-save').text @saving
        @saving = false
        @error.remove() if @error
        text = t 'connection failure' if ~text.indexOf('CORS request rejected')
        @error = $('<div>').addClass('button button-full button-energized')
        @error.text text
        @$(field or '#btn-save').before @error


