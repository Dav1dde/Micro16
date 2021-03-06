MIC = require 'mic'

trim = (s) -> (s or "").replace(/^\s+|\s+$/g, "")
contains = (value, array) -> $.inArray(value, array) >= 0

printBin = (num, length) ->
    ret = num.toString(2)
    ret = "0" + ret while ret.length < length
    return ret


toUpperCaseSafe = (inp) -> if typeof inp == "string" then inp.toUpperCase() else inp

WRITE_REGISTER = ["PC", "R0", "R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9", "R10", "AC", "MAR", "MBR"]
READ_REGISTER = ["0", "1", "-1"].concat(WRITE_REGISTER)

LABEL_RE = /:(\w+)$/
REGISTER_RE = /^\s*(R10|R\d|PC|AC|MAR|MBR)\s*$/i
ALU_RE = /^(lsh|rsh\()?\(?(~)?(R10|R\d|PC|AC|MBR|\-?1|0)\s*([+,&])?\s*\(?(R10|R\d|PC|AC|MBR|\-?1|0)?\)?\)?$/i
GOTO_RE = /^(?:if\s+(N|Z))?\s*goto\s+(\d+|\.\w+)$/i

exports = class Parser
    constructor: ->
        @lines = []
        @parsedLines = []
        @label = {}
        @assembled = []

    parse: (text) =>
        line = null
        lines = text.split('\n')
        if lines.length > 256 then throw { name: "SyntaxError", message: "Instructions exceeding rom (max 256)!" }

        $.each lines, (i, line) =>
            origLine = line;
            line = trim(line.replace(/#.*/g, "").replace(/;\s*$/g, ""))

            # Remove labels, labels must be at the end!
            if LABEL_RE.test(line)
                label = line.match(LABEL_RE)
                line = line.replace(LABEL_RE, "")
                if @label[label[1]] then throw { name: "SyntaxError", message: "Redefined label", line: i }
                @label[label[1]] = i

            if line.length == 0
                @parsedLines.push {}
                return

            elements = []
            for element in line.split(";")
                elements.push(trim(element))

            ins = {}
            for element in elements
                tmp = switch
                    when /<-/.test(element) then @parseLoad(element, i)
                    when /^(rd|wr)$/.test(line) then @parseRdwr(element, i)
                    when /(rd|wr)/.test(element) then @parseRdwr(element, i)
                    when GOTO_RE.test(element) then @parseGoto(element, i)
                    when ALU_RE.test(element) then @parseAlu(element, i)
                    else throw { name: "SyntaxError", message: "SyntaxError", line: i, more: element}

                console.log tmp

                for key, value of tmp
                    if not ins[key]
                        ins[key] = value
                    else
                        throw { name: "SyntaxError", message: "Multiple operations of same type", line: i, more: element }

            @lines.push origLine
            @parsedLines.push ins

        @assembleAll()

    parseLoad: (element, line) ->
        s = element.split(/<-/)
        if s.length != 2 then throw { name: "SyntaxError", message: "More than one <- found", line: line }
        s[0] = trim(s[0])
        s[1] = trim(s[1])

        if not REGISTER_RE.test(s[0])
            throw { name: "SyntaxError", message: "Unkown register", line: line }

        if not ALU_RE.test(s[1])
            throw { name: "SyntaxError", message: "Malformed ALU operation", line: line }

        write = toUpperCaseSafe(s[0])
        if !contains(write, WRITE_REGISTER) then throw { name: "SyntaxError", message: "Unknown register", line: line }

        alu = @parseAlu s[1], line
        alu["alu"]["S"] = write;

        return alu;


    parseAlu: (element, line) ->
        alu = element.match(ALU_RE)
        if !alu then throw { name: "SyntaxError", message: "Unable to parse ALU operation", line: line }
        if alu[2] and (alu[4] or alu[5]) then throw { name: "SyntaxError", message: "Only one operation allowed", line: line }

        shift = if alu[1] then alu[1].toLowerCase() else undefined
        alu_op = if alu[2] then alu[2] else alu[4]
        alu_op = if alu_op then alu_op else "="

        if contains(alu_op, ["&", "+"]) and !alu[5] then throw { name: "SyntaxError", message: "Need second register for ALU operation", line: line }
        if alu_op == "=" and alu[5] then throw { name: "SyntaxError", message: "Invalid ALU operation", line: line }


        return { alu : { A: toUpperCaseSafe(alu[3]), B: toUpperCaseSafe(alu[5]), op: alu_op }, shift: shift}

    parseGoto: (element, line) ->
        g = element.match(GOTO_RE)
        if !g then throw { name: "SyntaxError", message: "Malformed goto", line: line }

        return { target: g[2], condition: toUpperCaseSafe(g[1]) }


    parseRdwr: (element, line) ->
        return { RW: element }

    assembleAll: ->
        @assembled = []
        ramReady = true
        for line, i in @parsedLines
            # empty lines {} are kept with a instruction of 0s
            al = @assemble(line, i)

            if !ramReady and !al.ms
                throw { name: "SyntaxError", message: "RAM needs time to fetch data", line: i }

            if al.ms then ramReady = !ramReady

            @assembled.push al

    assemble: (ins, i) ->
        code = { amux: 0, cond: 0, alu: 0, sh: 0, mbr: 0, mar: 0, rdwr: 0, ms: 0, ens: 0, sbus: 0, bbus: 0, abus: 0, addr: 0 }

        if ins["alu"]
            code.alu = switch
                when ins["alu"]["op"] == "+" then 1
                when ins["alu"]["op"] == "&" then 2
                when ins["alu"]["op"] == "~" then 3
                else 0

            switch ins["alu"]["A"]
                when "MBR"
                    code.abus = 0
                    code.amux = 1
                else
                    code.abus = $.inArray(ins["alu"]["A"], READ_REGISTER)
                    code.amux = 0
            if code.abus == -1 then throw { name: "SyntaxError", message: "ABUS -1" }

            code.bbus = if ins["alu"]["B"] then $.inArray(ins["alu"]["B"], READ_REGISTER) else 0

            switch ins["alu"]["S"]
                when "MBR"
                    code.sbus = 0
                    code.mbr = 1
                    code.ens = 0
                when "MAR"
                    code.bbus = code.abus
                    code.abus = 0
                    code.sbus = 0
                    code.mar = 1
                    code.ens = 0
                when undefined
                    code.sbus = 0
                    code.ens = 0
                else
                    code.sbus = $.inArray(ins["alu"]["S"], READ_REGISTER)
                    code.ens = 1

            code.sh = switch
                when ins["shift"] == "lsh" then 1
                when ins["shift"] == "rsh" then 2
                else 0

        code.cond = switch
            when ins["condition"] == "N" then 1
            when ins["condition"] == "Z" then 2
            when ins["target"] and !ins["condition"] then 3
            else 0

        code.addr = switch
            when ins["target"] then @getLocation(ins["target"], i)
            else 0

        code.rdwr = switch
            when ins["RW"] == "rd" then 1
            else 0 # on wr also 0

        code.ms = switch
            when ins["RW"] then 1
            else 0

        return code

    getLocation: (target, i) ->
        addr = parseInt(if /\.\w+/.test(target) then @label[target.slice(1)] else target)

        if isNaN(addr) or addr == undefined or addr == null
            throw { name: "SyntaxError", message: "Label \"" + target + "\" not found", line: i }

        return addr

    getFormattedIns: (join) ->
        ret = ""

        for line in @assembled
            ret += [printBin(line.amux, 1), printBin(line.cond, 2), printBin(line.alu, 2), printBin(line.sh, 2),
            printBin(line.mbr, 1), printBin(line.mar, 1), printBin(line.rdwr, 1), printBin(line.ms, 1), printBin(line.ens, 1),
            printBin(line.sbus, 4), printBin(line.bbus, 4), printBin(line.abus, 4), printBin(line.addr, 8)].join(join)
            ret += "\n"

        return ret

    makeMic: ->
        return new MIC(@assembled)


