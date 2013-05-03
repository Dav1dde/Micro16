VM = require 'vm'
Events = require 'events'

exports = class MIC
    constructor: (code) ->
        @code = code
        @addr = 0
        @vm = new VM()

        @events = new Events(@)

    step: ->
        if @addr == code.length then throw { name: "MICError", message: "End of Code reached" }

        cl = @code[@addr]

        @events.trigger("step", cl, @addr)

        @vm.step(cl)

        jumps = [
            () => @addr+1 # no jump
            () => if @vm.flags["N"] then cl.addr else @addr+1 # condition = N
            () => if @vm.flags["Z"] then cl.addr else @addr+1 # condition = Z
            () => cl.addr # always jump
        ]
        @addr = jumps[cl.cond]()

        @events.trigger("stepped", @vm, @addr)

        if @addr == code.length
            @events.trigger("stop")


