Parser = require 'parser'

class Main
    constructor: ->
        @parser = new Parser()
        @mic = null

        $("#parse").click =>
            @parser = new Parser()
            @parser.parse $("#code").val()
            $("#out").val(@parser.getFormattedIns("|"))
            @mic = @parser.makeMic()

        $("#step").click =>
            @mic.step()


# main entry point
$ ->
    main = new Main

    