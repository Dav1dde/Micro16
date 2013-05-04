Parser = require 'parser'

REGISTER_TABLE = '<table class="table table-condensed" id="reg-table">
    <tr><th class="first-col">Register</th><th>Value</th></tr>
    <tr><td>0</td><td class="m16-reg-key-0">0</td></tr>
    <tr><td>1</td><td class="m16-reg-key-1">1</td></tr>
    <tr><td>-1</td><td class="m16-reg-key--1">-1</td></tr>
    <tr><td>PC</td><td class="m16-reg-key-PC">0</td></tr>
    <tr><td>R0</td><td class="m16-reg-key-R0">0</td></tr>
    <tr><td>R1</td><td class="m16-reg-key-R1">0</td></tr>
    <tr><td>R2</td><td class="m16-reg-key-R2">0</td></tr>
    <tr><td>R3</td><td class="m16-reg-key-R3">0</td></tr>
    <tr><td>R4</td><td class="m16-reg-key-R4">0</td></tr>
    <tr><td>R5</td><td class="m16-reg-key-R5">0</td></tr>
    <tr><td>R6</td><td class="m16-reg-key-R6">0</td></tr>
    <tr><td>R7</td><td class="m16-reg-key-R7">0</td></tr>
    <tr><td>R8</td><td class="m16-reg-key-R8">0</td></tr>
    <tr><td>R9</td><td class="m16-reg-key-R9">0</td></tr>
    <tr><td>R10</td><td class="m16-reg-key-R10">0</td></tr>
    <tr><td>AC</td><td class="m16-reg-key-AC">0</td></tr>
</table>
<table class="table table-condensed" id="flag-table">
    <tr><th class="first-col">Flag</th><th>Value</th></tr>
    <tr><td>N</td><td class="m16-flag-n">0</td></tr>
    <tr><td>Z</td><td class="m16-flag-z">0</td></tr>
</table>'

RAM_TABLE = '<div class="ram-options">
    <input type="checkbox" name="ramautojump">Autojump to last modification</input>
</div>

<div class="ram-jump-to">
  <div class="pre-input">Jump To: </div>
  <div class="input-right"><input type="text" placeholder="Address"></text></div>
</div>

<table class="table table-condensed" id="ram-table">
    <tr><th class="first-col-ram">Address</th><th>Value</th></tr>
    <tr><td><span>0x0000</span>0000000000000000</td><td class="m16-reg-key-0">0000000000000000</td></tr>
    <tr><td><span>0x0000</span>0000000000000000</td><td class="m16-reg-key-1">0000000000000000</td></tr>
    <tr><td><span>0x0000</span>0000000000000000</td><td class="m16-reg-key-2">0000000000000000</td></tr>
    <tr><td><span>0x0000</span>0000000000000000</td><td class="m16-reg-key-3">0000000000000000</td></tr>
    <tr><td><span>0x0000</span>0000000000000000</td><td class="m16-reg-key-4">0000000000000000</td></tr>
    <tr><td><span>0x0000</span>0000000000000000</td><td class="m16-reg-key-5">0000000000000000</td></tr>
    <tr><td><span>0x0000</span>0000000000000000</td><td class="m16-reg-key-6">0000000000000000</td></tr>
    <tr><td><span>0x0000</span>0000000000000000</td><td class="m16-reg-key-7">0000000000000000</td></tr>
    <tr><td><span>0x0000</span>0000000000000000</td><td class="m16-reg-key-8">0000000000000000</td></tr>
    <tr><td><span>0x0000</span>0000000000000000</td><td class="m16-reg-key-9">0000000000000000</td></tr>
    <tr><td><span>0x0000</span>0000000000000000</td><td class="m16-reg-key-10">0000000000000000</td></tr>
    <tr><td><span>0x0000</span>0000000000000000</td><td class="m16-reg-key-11">0000000000000000</td></tr>
    <tr><td><span>0x0000</span>0000000000000000</td><td class="m16-reg-key-12">0000000000000000</td></tr>
    <tr><td><span>0x0000</span>0000000000000000</td><td class="m16-reg-key-13">0000000000000000</td></tr>
    <tr><td><span>0x0000</span>0000000000000000</td><td class="m16-reg-key-14">0000000000000000</td></tr>
    <tr><td><span>0x0000</span>0000000000000000</td><td class="m16-reg-key-15">0000000000000000</td></tr>
</table>'


# only for 16bit numbers!
toDecimal = (inp) -> return ((if (inp & (1 << 15)) > 0 then 0xffff << 16 else 0) | inp).toString()
toBin = (inp) -> return (1 << 16 | (inp & 0xffff)).toString(2).slice(1)
toHex = (inp) ->
    hex = (Number(inp) & 0xffff).toString(16)
    return "0x" + ("0000".substr(0, 4 - hex.length)) + hex.toUpperCase();


class Main
    constructor: ->
        @code = window.codemirror = CodeMirror.fromTextArea(document.getElementById('code'),
            mode: 'micro16',
            tabSize: 4,
            smartIndent: false,
            lineNumbers: true,
            lineWrapping: false,
            firstLineNumber: 0
            gutters:["currentline", "CodeMirror-linenumbers"])

        @asm = window.codemirror = CodeMirror.fromTextArea(document.getElementById('out'),
            mode: 'none',
            smartIndent: false,
            lineNumbers: false,
            lineWrapping: false,
            readOnly: true,
            gutter: false,
            firstLineNumber: 0)

        @parser = new Parser()
        @mic = null
        @convertFunc = null
        @updateConvertFunc("binary")

        @lastRegisters = ({ "0": 0, "1": 1, "-1": -1, PC: 0, R0: 0, R1: 0, R2: 0, R3: 0, R4: 0, R5: 0,
        R6: 0, R7: 0, R8: 0, R9: 0, R10: 0, AC: 0, MBR: 0, MAR: 0 })
        @lastFlags = {"N" : 0, "Z": 0}

        @lastErrorLine = -1
        @code.on("change", (cm, change) =>
            @parser = new Parser()

            $("#run").removeAttr("disabled")
            $("#step").removeAttr("disabled")
            $("#stop").removeAttr("disabled")
            $("#reset").removeAttr("disabled")

            if @lastErrorLine >= 0
                @asm.removeLineClass(@lastErrorLine, "background")

            try
                @parser.parse @code.getValue()
            catch error
                if error.name != "SyntaxError" then throw error

                $("#run").attr("disabled", "disabled")
                $("#step").attr("disabled", "disabled")
                $("#stop").attr("disabled", "disabled")
                $("#reset").attr("disabled", "disabled")


                @lastErrorLine = error.line
                #if error.line?
                #    @asm.addLineClass(error.line, "background", "code-error-bg")

                return

            @asm.setValue(@parser.getFormattedIns(""))
            @makeMic()
        )

        $("#step").click =>
            @mic.step()

        $("#reset").click =>
            @code.setGutterMarker((if @mic? then @mic.addr else 0), "currentline", null)
            @makeMic()

        @registerVisible = true

        $("#btn-register").click =>
            $("#btn-ram").parent().removeClass("active")
            $("#btn-register").parent().removeClass("active")
            $("#btn-register").parent().addClass("active")
            @registerVisible = true
            $("#info").children().remove()
            $("#info").append(REGISTER_TABLE)

        $("#btn-ram").click =>
            $("#btn-ram").parent().removeClass("active")
            $("#btn-register").parent().removeClass("active")
            $("#btn-ram").parent().addClass("active")
            @registerVisible = false
            $("#info").children().remove()
            $("#info").append(RAM_TABLE)
        $("#info").append(REGISTER_TABLE)

        @updateRegistersRam()

        $(".unit-binary").click => @updateConvertFunc "binary"
        $(".unit-decimal").click => @updateConvertFunc "decimal"
        $(".unit-hexadecimal").click => @updateConvertFunc "hexadecimal"


    makeMic: ->
        @mic = @parser.makeMic()

        @mic.events.on("step", => @code.setGutterMarker(@mic.addr, "currentline", null))
        @mic.events.on("stepped", => @updateRegistersRam())
        @mic.events.on("stop", =>
            $("#step").attr("disabled", "disabled")
            $("#run").attr("disabled", "disabled")
            $("#stop").attr("disabled", "disabled")
        )

        $("#step").removeAttr("disabled")
        $("#run").removeAttr("disabled")
        $("#stop").removeAttr("disabled")

        @updateRegistersRam()


    updateRegistersRam: ->
        if @registerVisible then @updateRegisters() else @updateRam()
        @setGutterMark(if @mic? then @mic.addr else 0)

    updateRegisters: ->
        registers = if @mic? then @mic.vm.register else @lastRegisters
        flags = if @mic? then @mic.vm.flags else @lastFlags

        for own key, value of registers
            j = $(".m16-reg-key-" + key)
            j.parent().removeClass("info")
            if @lastRegisters[key] != value then j.parent().addClass("info")
            j.text(@convertFunc value)

        for f in ["N", "Z"]
            j = $(".m15-flag-" + f.toLowerCase())
            j.parent().removeClass("info")
            if @lastFlags[f] != flags[f] then j.parent().addClass("info");
            j.text(@convertFunc flags[f])

        @lastRegisters = registers
        @lastFlags = flags

    updateRam: ->


    setGutterMark: (addr) ->
        element = document.createElement("div")
        element.innerHTML = "&rarr;"
        @code.setGutterMarker((if addr? then addr else @mic.attr), "currentline", element)

    updateConvertFunc: (unit) ->
        @convertFunc = switch
            when unit == "decimal" then toDecimal
            when unit == "hexadecimal" then (inp) -> return toHex(toDecimal(inp))
            else toBin

        @updateRegistersRam()


# main entry point
$ ->
    main = new Main()

    resize = ->
        height = $(window).height() - 120
        height5 = height / 5
        $(".CodeMirror").height(height)
        $("#register").height(height5 * 3)
        $("#ram").height(height5 * 2)

    $(window).resize resize

    resize()

    