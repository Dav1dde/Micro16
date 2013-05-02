
exports = class VM
    constructor: () ->
        @reset()


    reset: ->
        @register = { PC: 0, R0: 0, R1: 0, R2: 0, R3: 0, R4: 0, R5: 0,
        R6: 0, R7: 0, R8: 0, R9: 0, R10: 0, AC: 0, MBR: 0, MAR: 0 }

        @ram = new Array(Math.pow(2, 16))

    step: (code) ->
        # see parser
        # code = { amux: 0, cond: 0, alu: 0, sh: 0, mbr: 0, mar: 0, rdwr: 0, ms: 0, ens: 0, sbus: 0, bbus: 0, abus: 0, addr: 0 }






