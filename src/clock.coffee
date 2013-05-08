Events = require 'events'


exports = class Clock
    constructor: (@freq) ->
        @events = new Events(@)
        @paused = false
        @started = false

    start: ->
        @paused = false
        @started = true
        @update()

    update: ->
        if !@paused
            @events.trigger("update")
            setTimeout (() => @update()), 1000/@freq

    pause: ->
        @paused = true
        @started = false

    setFreq: (freq) ->
        @freq = freq