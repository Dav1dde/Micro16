trim = (s) -> (s or "").replace(/^\s+|\s+$/g, "")
contains = (value, array) -> $.inArray(value, array) >= 0

printBin = (num, length) ->
    ret = num.toString(2)
    ret = "0" + ret while ret.length < length
    return ret



WRITE_REGISTER = ["PC", "R0", "R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9", "R10", "AC", "MAR", "MBR"]
READ_REGISTER = ["0", "1", "-1"].concat(WRITE_REGISTER)

LABEL_RE = /:(\w+)$/
REGISTER_RE = /(R10|R\d|PC|AC|MAR|MBR)/
ALU_RE = /(lsh|rsh\()?\(?(~)?(R10|R\d|PC|AC|MBR|\-?1|0)([+,&])?\(?(R10|R\d|PC|AC|MBR|\-?1|0)?\)?\)?/
GOTO_RE = /^(?:if\s+(N|Z))?\s*goto\s+(\d+|\.[a-zA-Z]\w+)$/

exports = class Parser
    constructor: ->
        @lines = []
        @parsedLines = []
        @label = {}
        @assembled = []

    parse: (text) =>
        line = null
        $.each text.split('\n'), (i, line) =>
            origLine = line;
            line = trim(line.replace(/#.*/g, ""))

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
                    when /<-/.test(element) then @parseLoad(element, line)
                    when /^(rd|wr)$/.test(line) then @parseRdwr(element, line)
                    when /(rd|wr)/.test(element) then @parseRdwr(element, line)
                    when GOTO_RE.test(element) then @parseGoto(element, line)
                    when ALU_RE.test(element) then @parseAlu(element, line)
                    else throw { name: "SyntaxError", message: "SyntaxError at line: " + i, line: i }

                $.extend(ins, tmp)

            @lines.push origLine
            @parsedLines.push ins

        @assembleAll()

        console.log @assembled

    parseLoad: (element, line) ->
        s = element.split(/<-/)
        if s.length != 2 then throw { name: "SyntaxError", message: "More than one <- found", line: line }
        write = s[0]
        if !contains(write, WRITE_REGISTER) then throw { name: "SyntaxError", message: "Unknown register", line: line }

        alu = @parseAlu s[1]
        alu["alu"]["S"] = write;

        return alu;


    parseAlu: (element, line) ->
        alu = element.match(ALU_RE)
        if !alu then throw { name: "SyntaxError", message: "Unable to parse expression", line: line }
        if alu[2] and (alu[4] or alu[5]) then throw { name: "SyntaxError", message: "Only one operation allowed", line: line }

        shift = if alu[1] then alu[1].toLowerCase() else undefined
        alu_op = if alu[2] then alu[2] else alu[4]
        alu_op = if alu_op then alu_op else "="

        if contains(alu_op, ["&", "+"]) && !alu[5] then throw { name: "SyntaxError", message: "Need seconds register", line: line }

        return { alu : { A: alu[3], B: alu[5], op: alu_op }, shift: shift}

    parseGoto: (element, line) ->
        g = element.match(GOTO_RE)
        if !g then throw { name: "SyntaxError", message: "Malformed goto", line: line }

        return { target: g[2], condition: g[1] }


    parseRdwr: (element, line) ->
        return { RW: element }


    assembleAll: ->
        @assembled = []
        for line in @parsedLines
            # empty lines {} are kept with a instruction of 0s
            @assembled.push @assemble line

    assemble: (ins) ->
        code = { amux: 0, cond: 0, alu: 0, sh: 0, mbr: 0, mar: 0, rdwr: 0, ms: 0, ens: 0, sbus: 0, bbus: 0, abus: 0, addr: 0 }

        console.log ins

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
            when ins["target"] then @getLocation(ins["target"])
            else 0

        code.rdwr = switch
            when ins["RW"] == "rd" then 1
            else 0 # on wr also 0

        code.ms = switch
            when ins["RW"] then 1
            else 0

        return code

    getLocation: (target) ->
        return parseInt(if /\.[a-zA-Z]\w+/.test(target) then @label[target.slice(1)] else target)

    getFormattedIns: (join) ->
        ret = ""

        for line in @assembled
            ret += [printBin(line.amux, 1), printBin(line.cond, 2), printBin(line.alu, 2), printBin(line.sh, 2),
            printBin(line.mbr, 1), printBin(line.mar, 1), printBin(line.rdwr, 1), printBin(line.ms, 1), printBin(line.ens, 1),
            printBin(line.sbus, 4), printBin(line.bbus, 4), printBin(line.abus, 4), printBin(line.addr, 8)].join(join)
            ret += "\n"

        return ret


