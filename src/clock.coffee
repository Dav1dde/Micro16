Events = require 'events'


exports = class Clock
    constructor: (@freq) ->
        @events = new Events(@)
        @paused = false

    start: ->
        @paused = false
        @update()

    update: ->
        console.log "update"
        if !@paused
            @events.trigger("update")
            setTimeout (() => @update()), 1000/@freq

    pause: ->
        @paused = true

    setFreq: (freq) ->
        @freq = freq