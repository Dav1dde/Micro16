Events = require 'events'

exports = class Ram
    constructor: ->
        @ram = new Array(Math.pow(2, 16))
        for element, i in @ram
            @ram[i] = 0

        @ready = true

        @events = new Events(@)

    write: (pos, data) ->
        if !@ready
            @ready = true
            return false

        @ready = false
        @ram[pos] = data

        @events.trigger("write", pos, data)

        return true


    read: (pos, objOut) ->
        if !@ready
            @ready = true
            return false

        objOut["MBR"] = @ram[pos]

        @events.trigger("read", pos)

        return true

    get: (i) ->
        return @ram[i]

    set: (i, value) ->
        @ram[i] = value




