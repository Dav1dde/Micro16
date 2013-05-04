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
            @mic = @parser.makeMic()

            @mic.events.on("step", (mic, vm, addr) => @code.setGutterMarker(@mic.addr, "currentline", null))
            @mic.events.on("stepped", (mic, vm, addr) => @updateRegistersRam())
        )

        $("#step").click =>
            console.log "clicked step"
            @mic.step()

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

        @setGutterMark(0)


    updateRegistersRam: ->
        if @registerVisible then @updateRegisters() else @updateRam()
        @setGutterMark()

    updateRegisters: ->
        for own key, value of @mic.vm.register
            j = $(".m16-reg-key-" + key)
            j.parent().removeClass("info")
            if parseInt(j.text()) != value
                j.parent().addClass("info")
            j.text(value)

        $(".m15-flag-n").text(@mic.vm.flags.N)
        $(".m15-flag-n").text(@mic.vm.flags.Z)

    updateRam: ->

    setGutterMark: (addr) ->
        element = document.createElement("div")
        element.innerHTML = "&rarr;"
        @code.setGutterMarker((if addr? then addr else @mic.attr), "currentline", element)





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

    