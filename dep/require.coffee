modules = {}

abspath = (fromName, pathName) ->
    baseName = fromName.split('/')
    baseName.pop()
    baseName = baseName.join('/')

    if pathName[0] == '/'
        return pathName
    else
        path = pathName.split '/'
        if baseName == '/'
            base = ['']
        else
            base = baseName.split '/'

        while base.length > 0 and path.length > 0 and path[0] == '..'
            base.pop()
            path.shift()

        if base.length == 0 || path.length == 0 || base[0] != ''
            throw "Invalid path: #{base.join '/'}/#{path.join '/'}"
        return "#{base.join('/')}/#{path.join('/')}"

window.define = (moduleName, closure) ->
    modules[moduleName] = {
        closure: closure
        instance: null
    }

window.require = globalRequire = (moduleName) ->
    module = modules[moduleName]

    if module == undefined
        throw 'Module not found: ' + moduleName

    if module.instance == null
        moduleRequire = (requirePath) ->
            path = abspath(moduleName, requirePath)
            return globalRequire(path)

        exports = {}
        exports = module.closure(exports, moduleRequire)
        module.instance = exports

    return module.instance
