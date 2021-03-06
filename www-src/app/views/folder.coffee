CollectionView = require '../lib/view_collection'

module.exports = class FolderView extends CollectionView


    className: 'list'
    itemview: require './folder_line'
    events: ->
        'tap .cache-indicator': 'displaySlider'
        'hold .item': 'displaySlider'

    isParentOf: (otherFolderView) ->
        return true if @collection.path is null #root
        return false if @collection.isSearch()
        return false unless otherFolderView.collection.path
        return -1 isnt otherFolderView.collection.path.indexOf @collection.path

    initialize: ->
        super
        @listenTo @collection, 'sync', @onChange

    afterRender: ->
        @ionicView?.destroy()
        super
        @ionicView = new ionic.views.ListView
            el: @$el[0]
            _handleDrag: (e) ->
                ionic.views.ListView::_handleDrag.apply this, arguments
                # prevent menu from opening
                e.stopPropagation()

    onChange: =>
        @$('#empty-message').remove()
        if _.size(@views) is 0

            message = if @collection.notloaded then 'loading'
            else if @collection.isSearch() then 'no results'
            else 'this folder is empty'

            $('<li class="item" id="empty-message">')
            .text(t(message))
            .appendTo @$el

    appendView: (view) =>
        super
        view.parent = this

    remove: =>
        super
        @collection.cancelFetchAdditional()

    displaySlider: (event) =>
        console.log "DISPLAY SLIDER"
        # simulate a drag effect on the line to display the hidden button
        @ionicView.clearDragEffects()
        op = new ionic.SlideDrag(el: @ionicView.el, canSwipe: -> true)
        op.start target: event.target
        dX = if op._currentDrag.startOffsetX is 0 then 0 - op._currentDrag.buttonsWidth
        else op._currentDrag.buttonsWidth
        op.end gesture:
            deltaX: dX
            direction: 'right'
        ionic.requestAnimationFrame => @ionicView._lastDragOp = op
        event.preventDefault()
        event.stopPropagation()