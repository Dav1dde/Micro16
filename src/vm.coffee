Ram = require 'ram'


WRITE_REGISTER = ["PC", "R0", "R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9", "R10", "AC", "MAR", "MBR"]
READ_REGISTER = ["0", "1", "-1"].concat(WRITE_REGISTER)

exports = class VM
    constructor: () ->
        @reset()

    reset: ->
        @register = ({ "0": 0, "1": 1, "-1": -1, PC: 0, R0: 0, R1: 0, R2: 0, R3: 0, R4: 0, R5: 0,
        R6: 0, R7: 0, R8: 0, R9: 0, R10: 0, AC: 0, MBR: 0, MAR: 0 })
        @flags = {N: 0, Z: 0}

        @ram = new Ram()

    step: (code, line) ->
        # see parser
        # code = { amux: 0, cond: 0, alu: 0, sh: 0, mbr: 0, mar: 0, rdwr: 0, ms: 0, ens: 0, sbus: 0, bbus: 0, abus: 0, addr: 0 }

        # A and amux
        A = switch
            when code.amux == 1 and code.rdwr == 1 then "MBR"
            when code.amux == 1 then
            else READ_REGISTER[code.abus]

        # B
        B = READ_REGISTER[code.bbus]

        # pass contents of "bbus" to register MAR if, activated
        if code.mar
            @register["MAR"] = @register[B]
            return

        if code.sbus < 3 and code.ens then throw { name: "VMError", message: "Tried to write into readonly register" }

        S = switch
            when code.ens then READ_REGISTER[code.sbus]
            when !code.ens and code.mbr then "MBR"

        # ALU operations:
        # 0 | 0 0 | R <- A
        # 1 | 0 1 | R <- A + B
        # 2 | 1 0 | R <- A & B
        # 3 | 1 1 | R <- ~A

        aluOperations = [
            (A, B) -> A
            (A, B) -> (A + B) & 0xffff
            (A, B) -> (A & B) & 0xffff
            (A, B) -> (~A) & 0xffff
        ]
        aluOp = aluOperations[code.alu]

        # SHIFT operations:
        # 0 | 00 | S <- R
        # 1 | 01 | S <- lsh(R)
        # 2 | 10 | S <- rsh(R)
        # 3 | 11 | undefined
        shiftOperations = [
            (R) -> R
            (R) -> (R << 1) & 0xffff
            (R) -> (R >> 1) & 0xffff
            (R) -> throw { name: "VMError", message: "Invalid shift", line: line }
        ]
        shiftOp = shiftOperations[code.sh]

        aluResult = aluOp(@register[A], @register[B])
        @flags["N"] = ((aluResult >> 15) & 1) == 1 # negative flag
        @flags["Z"] = aluResult == 0 # zero flag

        shiftResult = shiftOp(aluResult)

        # write output to register
        @register[S] = shiftResult

        # io
        if code.ms
            if code.rdwr == 0 # write
                @ram.write(@register["MAR"], @register["MBR"])
            else # ram
                @ram.read(@register)
        else
            # should never happen, we checked this in the parser already
            if !@ram.ready then throw { name: "VMError", message: "Slow doooown! Ram is not ready yet.", line: line }











