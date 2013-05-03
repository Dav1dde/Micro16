exports = class Events
    constructor: (@obj) ->
        @handlersByType = {}

    on: (name, handler) ->
        handlers = @handlersByType[name] ?= []
        handlers.push handler
        return @

    remove: ->
        @handlersByType = {}

    trigger: (name, arg1, arg2, arg3, arg4, arg5, arg6) ->
        handlers = @handlersByType[name]
        if handlers
            for handler in handlers
                handler.call(@obj, arg1, arg2, arg3, arg4, arg5, arg6)
        return
