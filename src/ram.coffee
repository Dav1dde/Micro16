

exports = class Ram
    constructor: ->
        @ram = new Array(Math.pow(2, 16))
        @ready = true

    write: (pos, data) ->
        if !@ready
            @ready = true
            return false

        @ready = false
        @ram[pos] = data

        return true


    read: (pos, objOut) ->
        if !@ready
            @ready = true
            return false

        objOut["MBR"] = @ram[pos]

        return true




