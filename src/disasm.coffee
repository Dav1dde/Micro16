trim = (s) -> (s or "").replace(/^\s+|\s+$/g, "")

WRITE_REGISTER = ["PC", "R0", "R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9", "R10", "AC", "MAR", "MBR"]
READ_REGISTER = ["0", "1", "-1"].concat(WRITE_REGISTER)

exports = class Disassembler
    constructor: ->


    disassembleLines: (text) ->
        dis = []
        ins = []

        nb = text.replace(/\r?\n/g, "").replace(/\s+/g, "")
        if nb.length == 0 then return {dis: [], ins: []}

        if /^[0-9a-fA-F]+$/.test(nb) and (nb.length % 8) == 0 and /^[a-fA-F]+$/.test(nb)
            lines = nb.match(/[0-9a-fA-F]{8}/g, nb)
        else
            lines = text.split('\n')

        if lines.length > 256 then throw { name: "DisassemblerError", message: "Instructions exceeding rom (max 256)!" }

        radix = switch
            when /^[01]+$/.test(nb) then 2
            #when /^[0-9]+$/.test(nb) then 10
            when /^(?:[0-9a-fA-F]{8})+$/.test(nb) then 16
            when /^(?:0x[0-9a-fA-F]{8})+$/.test(nb) then 16
            else throw { name: "DisassemblerError", message: "Ambiguous opcode format." }

        $.each lines, (i, line) =>
            line = trim(line.replace(/\s*/g, ""))
            if not line or not line.length then line = 0

            d = @disassemble(line, i, radix)
            dis.push d["disasm"]
            ins.push d["intins"]

            return

        return {dis: dis, ins: ins}


    disassemble: (line, i, radix) ->
        # do it the low level way!
        # this works since JS uses 32 bit integer and our instructions
        # are exactly 32 bit long!
        intins = 0
        if not radix
            intins = parseInt(line)
            if not (typeof line == "number")
                intins = switch
                    when /^[01]+$/.test(line) then parseInt(line, 2)
                    #when /^[0-9]+$/.test(line) then parseInt(line, 10)
                    #when /^[0-9a-fA-F]{8}$/.test(line) then parseInt(line, 16)
                    when /^(?:0x)?[0-9a-fA-F]{8}$/.test(line) then parseInt(line, 16)
                    else throw { name: "DisassemblerError", message: "Broken opcode", line: i }
        else
            intins = parseInt(line, radix)

        if isNaN(intins)
            throw { name: "DisassemblerError", message: "Broken opcode", line: i }

        if intins == 0 then return {disasm: "", intins: intins}

        ins = {
            amux: (intins >> 31) & 1, # 1 = 01
            cond: (intins >> 29) & 3, # 3 = 11
            alu: (intins >> 27) & 3,
            sh: (intins >> 25) & 3,
            mbr: (intins >> 24) & 1,
            mar: (intins >> 23) & 1,
            rdwr: (intins >> 22) & 1,
            ms: (intins >> 21) & 1,
            ens: (intins >> 20) & 1,
            sbus: (intins >> 16) & 15, # 15 = 0x0f = 1111
            bbus: (intins >> 12) & 15,
            abus: (intins >> 8) & 15,
            addr: intins & 255 # 255 = 0xff = 11111111
        }

        pre = ""
        ret = []

        A = switch
            when ins.amux then "MBR"
            else READ_REGISTER[ins.abus]

        B = READ_REGISTER[ins.bbus]

        # more of a hack...
        if ins.mar and ins.mbr and ins.ms and not ins.ens
            pre = "MBR <- " + A + "\n"

        if ins.mar
            A = B
            B = "0"

        S = switch
            when ins.mar then "MAR"
            when ins.mbr then "MBR"
            when ins.sbus and ins.ens then READ_REGISTER[ins.sbus]
            else undefined

        op = switch
            when ins.alu == 1 then "+"
            when ins.alu == 2 then "&"
            when ins.alu == 3 then "~"
            else "=" # this should never appear!

        shift = switch
            when ins.sh == 1 then "lsh"
            when ins.sh == 2 then "rsh"
            when ins.sh >= 3 then throw { name: "DisassemblerError", message: "Invalid Shift", line: i }
            else ""

        cond = switch
            when ins.cond == 0 then "NO JUMP" # this should never appear
            when ins.cond == 1 then "N"
            when ins.cond == 2 then "Z"
            else "ALWAYS JUMP" # this should never appear

        addr = ins.addr

        result = switch
            when ins.alu == 0 then A
            when ins.alu == 1 or ins.alu == 2 and B then A + op + B
            when ins.alu == 3 then "~" + A
            else ""

        if ins.sh then result = shift + "(" + result + ")"

        result = switch
            when S then result = S + " <- " + result
            when result.length then result = "(" + result + ")"
            else ""
        # "(0)" if: "goto X"
        if result.length and result != "(0)" then ret.push result

        result = switch
            when ins.ms and ins.rdwr == 1 then "rd"
            when ins.ms and ins.rdwr == 0 then "wr"
            else ""
        if result.length then ret.push result

        result = switch
            when ins.cond == 1 then "if N goto " + addr
            when ins.cond == 2 then "if Z goto " + addr
            when ins.cond == 3 then "goto " + addr
            else ""
        if result.length then ret.push result

        return {disasm: pre + ret.join("; "), intins: intins}








