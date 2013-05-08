VM = require 'vm'
Events = require 'events'
Clock = require 'clock'

exports = class MIC
    constructor: (code, freq) ->
        @code = code
        @addr = 0
        @vm = new VM()
        @clock = new Clock(if freq then freq else 1)
        @ispaused = false

        @events = new Events(@)

    step: ->
        if @isFinished() then throw { name: "MICError", message: "End of Code reached" }
        @ispaused = false

        cl = @code[@addr]

        @events.trigger("step", cl, @addr)
        if @ispaused
            return

        @vm.step(cl, @addr)

        jumps = [
            () => @addr+1 # no jump
            () => if @vm.flags["N"] then cl.addr else @addr+1 # condition = N
            () => if @vm.flags["Z"] then cl.addr else @addr+1 # condition = Z
            () => cl.addr # always jump
        ]
        @addr = jumps[cl.cond]()

        @events.trigger("stepped", @vm, @addr)

        if @addr == @code.length
            @clock.pause()
            @events.trigger("stop")

    run: =>
        @clock.events.on("update", () => @step())
        @clock.start()
        @ispaused = false

    pause: =>
        @clock.pause()
        @clock.events.remove()
        @ispaused = true

    setSpeed: (hz) =>
        @clock.setFreq(hz)

    isFinished: ->
        return @addr == @code.length



