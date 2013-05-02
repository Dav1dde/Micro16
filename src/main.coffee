Parser = require 'parser'

class Main
    constructor: ->
        @parser = new Parser()

        $("#parse").click =>
            @parser.parse $("#code").val()



# main entry point
$ ->
    main = new Main

    