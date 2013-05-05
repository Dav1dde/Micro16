Parser = require 'parser'

EXAMPLE_CODE = 'IyMjIE11bHRpcGxpY2F0aW9uIG9mIHR3byBudW1iZXJzClI3PC1sc2goMSsxKQpSNzwtUjcrUjcK\nUjg8LTAKUjY8LSgxKzEpClI2PC' +
'1SNisxCk1BUjwtUjY7cmQKcmQKUjk8LU1CUgpSNjwtUjYrMQpN\nQVI8LVI2O3JkCnJkClIxMDwtTUJSClI5PC1sc2goUjkrUjkpClI5PC1sc2goUjkrUjk' +
'pClI5PC1s\nc2goUjkrUjkpClI5PC1sc2goUjkrUjkpCihSNyk7IGlmIFogZ290byAyNApSODwtbHNoKFI4KQoo\nflI5KTsgaWYgTiBnb3RvIDIxClI4PC' +
'1SOCtSMTAKUjk8LWxzaChSOSkKUjc8LVI3KygtMSkKZ290\nbyAxNwpSNjwtUjYrUjYKUjY8LVI2KzEKTUFSPC1SNgpNQlI8LVI4O3dyCndy\n'

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
    <tr><td>MAR</td><td class="m16-reg-key-MAR">0</td></tr>
    <tr><td>MBR</td><td class="m16-reg-key-MBR">0</td></tr>
</table>
<table class="table table-condensed" id="flag-table">
    <tr><th class="first-col">Flag</th><th>Value</th></tr>
    <tr><td>N</td><td class="m16-flag-n">0</td></tr>
    <tr><td>Z</td><td class="m16-flag-z">0</td></tr>
</table>
<a class="btn pull-right btn-small clear-register">Reset Register</a>'

RAM_TABLE = '<div class="ram-options">
    <input type="checkbox" name="ramautojump" id="ramautojump">Autojump to last modification</input>
</div>

<div class="ram-jump-to">
  <div class="pre-input">Jump To: </div>
  <div class="input-right"><input type="text" placeholder="Address" id="ram-addr"></text></div>
</div>

<table class="table table-condensed" id="ram-table">
    <tr><th class="first-col-ram">Address</th><th>Value</th></tr>
    <tr class="m16-ram-0"><td><span>0x0000</span><span>0000000000000000</span></td><td>0000000000000000</td></tr>
    <tr class="m16-ram-1"><td><span>0x0000</span><span>0000000000000000</span></td><td>0000000000000000</td></tr>
    <tr class="m16-ram-2"><td><span>0x0000</span><span>0000000000000000</span></td><td>0000000000000000</td></tr>
    <tr class="m16-ram-3"><td><span>0x0000</span><span>0000000000000000</span></td><td>0000000000000000</td></tr>
    <tr class="m16-ram-4"><td><span>0x0000</span><span>0000000000000000</span></td><td>0000000000000000</td></tr>
    <tr class="m16-ram-5"><td><span>0x0000</span><span>0000000000000000</span></td><td>0000000000000000</td></tr>
    <tr class="m16-ram-6"><td><span>0x0000</span><span>0000000000000000</span></td><td>0000000000000000</td></tr>
    <tr class="m16-ram-7"><td><span>0x0000</span><span>0000000000000000</span></td><td>0000000000000000</td></tr>
    <tr class="m16-ram-8"><td><span>0x0000</span><span>0000000000000000</span></td><td>0000000000000000</td></tr>
    <tr class="m16-ram-9"><td><span>0x0000</span><span>0000000000000000</span></td><td>0000000000000000</td></tr>
    <tr class="m16-ram-10"><td><span>0x0000</span><span>0000000000000000</span></td><td>0000000000000000</td></tr>
    <tr class="m16-ram-11"><td><span>0x0000</span><span>0000000000000000</span></td><td>0000000000000000</td></tr>
    <tr class="m16-ram-12"><td><span>0x0000</span><span>0000000000000000</span></td><td>0000000000000000</td></tr>
    <tr class="m16-ram-13"><td><span>0x0000</span><span>0000000000000000</span></td><td>0000000000000000</td></tr>
    <tr class="m16-ram-14"><td><span>0x0000</span><span>0000000000000000</span></td><td>0000000000000000</td></tr>
    <tr class="m16-ram-15"><td><span>0x0000</span><span>0000000000000000</span></td><td>0000000000000000</td></tr>
</table>
<a class="btn pull-right btn-small clear-ram">Clear Ram</a>
'

EMPTY_REGISTER = ({ "0": 0, "1": 1, "-1": -1, PC: 0, R0: 0, R1: 0, R2: 0, R3: 0, R4: 0, R5: 0,
R6: 0, R7: 0, R8: 0, R9: 0, R10: 0, AC: 0, MBR: 0, MAR: 0 })


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

        @userRegister = $.extend({}, EMPTY_REGISTER)
        @lastRegister = $.extend({}, EMPTY_REGISTER)
        @lastFlags = {"N" : 0, "Z": 0}

        @userRam = new Array(Math.pow(2, 16))
        for element, i in @userRam
            @userRam[i] = 0

        @ramStartPos = 0

        @lastErrorLine = -1
        @code.on("change", (cm, change) =>
            @parser = new Parser()

            $("#run").removeAttr("disabled")
            $("#step").removeAttr("disabled")
            $("#pause").removeAttr("disabled")
            $("#reset").removeAttr("disabled")

            $(".status-text").text("Stopped")
            $(".status-text").css("color", "green")

            if @lastErrorLine >= 0
                @asm.removeLineClass(@lastErrorLine, "background")

            try
                @parser.parse @code.getValue()
            catch error
                if error.name != "SyntaxError" then throw error

                $("#run").attr("disabled", "disabled")
                $("#step").attr("disabled", "disabled")
                $("#pause").attr("disabled", "disabled")
                $("#reset").attr("disabled", "disabled")

                $(".status-text").text(error.message + " | At line: " + error.line)
                $(".status-text").css("color", "red")


                @lastErrorLine = error.line
                #if error.line?
                #    @asm.addLineClass(error.line, "background", "code-error-bg")

                return

            @asm.setValue(@parser.getFormattedIns(""))
            @code.clearGutter("currentline")
            @makeMic()
        )

        $("#step").click =>
            @mic.step()
            if !@mic.isFinished() then $(".status-text").text("Paused")

        $("#reset").click =>
            @code.setGutterMarker((if @mic? then @mic.addr else 0), "currentline", null)
            @mic.pause()
            @makeMic()
            @updateRegistersRam()

        $("#run").click =>
            @mic.run()
            $("#run").attr("disabled", "disabled")
            $("#step").attr("disabled", "disabled")
            $("#pause").removeAttr("disabled")
            $(".status-text").text("Running")

        $("#pause").click =>
            @mic.pause()
            $("#pause").attr("disabled", "disabled")
            $("#step").removeAttr("disabled")
            $("#run").removeAttr("disabled")
            $(".status-text").text("Paused")

        $("#clockSpeed").keyup =>
            value = parseInt($("#clockSpeed").val())
            @mic.setSpeed(if value then value else 1)

        $("#clockSpeed").change =>
            value = parseInt($("#clockSpeed").val())
            @mic.setSpeed(if value then value else 1)


        @registerVisible = true

        $("#btn-register").click =>
            $("#btn-ram").parent().removeClass("active")
            $("#btn-register").parent().removeClass("active")
            $("#btn-register").parent().addClass("active")
            @registerVisible = true
            $("#info").children().remove()
            $("#info").append(REGISTER_TABLE)
            @updateRegistersRam()

            $("#reg-table tbody tr:gt(3)").dblclick (event) =>
                Jregister = $("td:nth-child(2)", $(event.target).parent())
                register = Jregister.attr("class").match(/\w+$/)

                Jregister.text("")
                inp = $('<input type="text" data-toggle="tooltip" class="inj-reg"></input>')
                    .css("margin", "0")
                    .css("padding", "0")
                    .css("height", Jregister.height()-2 + "px")
                    .css("width", "150px")
                    .attr("title", "Invalid Input. Correct Unit?")
                    .data({register: register})
                    .appendTo(Jregister)

                inp.keypress (event) =>
                    if event.which == 13 then Jregister.click()

                #inp.tooltip()

            $("#reg-table tbody tr:gt(3)").click (event) =>
                Jregister = $("td:nth-child(2)", $(event.target).parent())
                inp = Jregister.find("input")
                register = $("td:nth-child(1)", $(event.target).parent()).text()

                text = inp.val()
                value = switch
                    when not text then 0
                    when text.length > 2  and text[0] == "0" and text[1] == "x" then parseInt(text, 16) & 0xffff
                    when @unitMode == "decimal" then parseInt(text, 10) & 0xffff
                    when @unitMode == "hexadecimal" then parseInt(text, 16) & 0xffff
                    when @unitMode == "binary" and not /[01]+/.test(text) then NaN
                    else parseInt(text, 2) & 0xffff

                if isNaN(value)
                    inp.tooltip()
                    inp.tooltip("show")
                    setTimeout((() => inp.tooltip("destroy")), 1100)
                    return

                @userRegister[register] = value
                reg = @userRegister
                if @mic
                    @mic.vm.register[register] = value
                    reg = @mic.vm.register
                Jregister.text(@convertFunc reg[register])

            $(".clear-register").click =>
                @userRegister = $.extend({}, EMPTY_REGISTER)
                @updateRegistersRam()


        $("#btn-ram").click =>
            $("#btn-ram").parent().removeClass("active")
            $("#btn-register").parent().removeClass("active")
            $("#btn-ram").parent().addClass("active")
            @registerVisible = false
            $("#info").children().remove()
            $("#info").append(RAM_TABLE)
            @updateRegistersRam()

            $("#ram-addr").keyup =>
                text = $("#ram-addr").val()
                @ramStartPos = switch
                    when text.length > 2 and text[0] == "0" and text[1] == "x" then parseInt(text, 16) & 0xffff
                    when @unitMode == "decimal" then parseInt(text, 10) & 0xffff
                    when @unitMode == "hexadecimal" then parseInt(text, 16) & 0xffff
                    when @unitMode == "binary" and not /[01]+/.test(text) then NaN
                    else parseInt(text, 2) & 0xffff

                if isNaN(@ramStartPos) and @ramStartPos?
                    @ramStartPos = 0

                @updateRegistersRam()

            $("#ram-table tbody tr:gt(0)").dblclick (event) =>
                Jram = $("td:nth-child(2)", $(event.target).parent())
                ramcol = Jram.parent().attr("class").match(/\w+$/)

                Jram.text("")
                inp = $('<input type="text" data-toggle="tooltip" class="inj-reg"></input>')
                    .css("margin", "0")
                    .css("padding", "0")
                    .css("height", Jram.height()-2 + "px")
                    .css("width", "150px")
                    .attr("title", "Invalid Input. Correct Unit?")
                    .data({ram: ramcol})
                    .appendTo(Jram)

                inp.keypress (event) =>
                    if event.which == 13 then Jram.click()

            $("#ram-table tbody tr:gt(0)").click (event) =>
                Jram = $("td:nth-child(2)", $(event.target).parent())
                inp = Jram.find("input")
                ramAddr = $("td:nth-child(1) span:nth-child(1)", $(event.target).parent()).text()
                ramAddr = parseInt(ramAddr, 16)

                text = inp.val()
                value = switch
                    when not text then 0
                    when text.length > 2  and text[0] == "0" and text[1] == "x" then parseInt(text, 16) & 0xffff
                    when @unitMode == "decimal" then parseInt(text, 10) & 0xffff
                    when @unitMode == "hexadecimal" then parseInt(text, 16) & 0xffff
                    when @unitMode == "binary" and not /[01]+/.test(text) then NaN
                    else parseInt(text, 2) & 0xffff

                if isNaN(value)
                    inp.tooltip()
                    inp.tooltip("show")
                    setTimeout((() => inp.tooltip("destroy")), 1100)
                    return

                @userRam[ramAddr] = value
                ram = @userRam
                if @mic
                    @mic.vm.ram.ram[ramAddr] = value
                    ram = @mic.vm.ram.ram
                Jram.text(@convertFunc ram[ramAddr])

            $(".clear-ram").click =>
                for element, i in @userRam
                    @userRam[i] = 0
                @updateRegistersRam()

        $(".load-example").click =>
            $("#aboutModal").modal('hide')
            @code.setValue($.base64('atob', EXAMPLE_CODE))

        # tab which is open by default
        $("#btn-register").click()

        $(".unit-binary").click =>
            @updateConvertFunc "binary"
            @updateRegistersRam()
        $(".unit-decimal").click =>
            @updateConvertFunc "decimal"
            @updateRegistersRam()
        $(".unit-hexadecimal").click =>
            @updateConvertFunc "hexadecimal"
            @updateRegistersRam()

    makeMic: ->
        @mic = null
        @updateRegistersRam()
        @mic = @parser.makeMic()
        @mic.vm.register = $.extend({}, @userRegister)
        @mic.vm.ram.ram = @userRam.slice()

        @mic.events.on("step", => @code.setGutterMarker(@mic.addr, "currentline", null))
        @mic.events.on("stepped", => @updateRegistersRam())
        @mic.events.on("stop", =>
            $("#step").attr("disabled", "disabled")
            $("#run").attr("disabled", "disabled")
            $("#pause").attr("disabled", "disabled")
            $(".status-text").text("Finished")
        )

        @mic.setSpeed(parseInt($("#clockSpeed").val()) or 1)

        $("#step").removeAttr("disabled")
        $("#run").removeAttr("disabled")
        $("#pause").removeAttr("disabled")
        $("#pause").attr("disabled", "disabled")
        $(".status-text").text("Stopped")

        @mic.vm.ram.events.on("write", (pos, data) =>
            if $("input[name=ramautojump]").prop("checked") then @ramStartPos = pos
            @updateRegistersRam()
        )
        @mic.vm.ram.events.on("read", (pos) => @updateRegistersRam())


    updateRegistersRam: ->
        if @registerVisible
            @updateRegisters()
        else
            @updateRam()

        @code.clearGutter("currentline")
        @setGutterMark(if @mic? then @mic.addr else 0)

    updateRegisters: ->
        registers = if @mic? then @mic.vm.register else @userRegister
        flags = if @mic? then @mic.vm.flags else @lastFlags

        for own key, value of registers
            j = $(".m16-reg-key-" + key)
            j.parent().removeClass("info")
            if @lastRegister[key] != value then j.parent().addClass("info")
            j.text(@convertFunc value)

        for f in ["N", "Z"]
            j = $(".m16-flag-" + f.toLowerCase())
            j.parent().removeClass("info")
            if @lastFlags[f] != flags[f] then j.parent().addClass("info");
            j.text(@convertFunc flags[f])

        @lastRegister = registers
        @lastFlags = flags

    updateRam: ->
        ram = if @mic? then @mic.vm.ram else {get: (i) => @userRam[i]}

        for i in [0..15]
            ii = @ramStartPos+i

            s = ".m16-ram-" + i

            #rotate!
            $(s + " td:last-child").text(@convertFunc ram.get(parseInt(toDecimal(toBin(ii)), 2)))
            $(s + " td:first-child span:nth-child(1)") .text(toHex(ii))
            $(s + " td:first-child span:nth-child(2)") .text(toBin(ii))


    setGutterMark: (addr) ->
        element = document.createElement("div")
        element.innerHTML = "&rarr;"
        @code.setGutterMarker((if addr? then addr else @mic.attr), "currentline", element)

    updateConvertFunc: (unit) ->
        $(".unit-binary").parent().parent().find("i").remove()

        @unitMode = unit

        switch unit
            when "decimal"
                $(".unit-decimal").html("Decimal <i class=\"icon-ok\">")
                @convertFunc = toDecimal
            when "hexadecimal"
                $(".unit-hexadecimal").html("Hexadecimal <i class=\"icon-ok\">")
                @convertFunc = (inp) -> return toHex(toDecimal(inp))
            else
                $(".unit-binary").html("Binary <i class=\"icon-ok\">")
                @convertFunc = toBin
                @unitMode = "binary"


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

    