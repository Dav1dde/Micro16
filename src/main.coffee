Parser = require 'parser'

class Main
    constructor: ->
        @parser = new Parser()

        $("#parse").click =>
            @parser = new Parser()
            @parser.parse $("#code").val()
            $("#out").val(@parser.getFormattedIns(""))



# main entry point
$ ->
    main = new Main

    