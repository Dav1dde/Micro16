#!/usr/bin/env python2

# credits go to: Florian Boesch @ http://codeflow.org/

from marshal import loads, dumps
from os import walk, stat
from os.path import exists, join, realpath, dirname, splitext, basename
from stat import ST_MTIME
from subprocess import Popen, PIPE
from datetime import datetime
from sys import argv, stdout

try:
    import json
    jsonEncode = json.dumps
except ImportError:
    try:
        import cjson
        jsonEncode = cjson.encode
    except ImportError:
        try:
            import simplejson
            jsonEncode = simplejson.dumps
        except ImportError:
            sys.exit(-1)

class CoffeeError(Exception): pass

message_count = 0
def message(text):
    global message_count
    now = datetime.now().strftime('%H:%M:%S')
    print '[%04i %s] %s' % (message_count, now, text)
    message_count+=1

def error(text):
    stdout.write('\x1b[31m%s\x1b[39m' % text)
    stdout.flush()

def modified(path):
    return stat(path)[ST_MTIME]

def files(directory, ext=None):
    result = []
    for root, dirs, files in walk(directory):
        for file in files:
            if ext != None and file.endswith(ext):
                result.append(join(root, file))
            else:
                result.append(join(root, file))
    return result

def preprocess(source, name):
    result = []
    for lineno, line in enumerate(source.split('\n')):
        line = line.replace('//essl', '#line %i %s' % (lineno+1, basename(name)))
        result.append(line)
    return '\n'.join(result)

def wrap(source, moduleName):
    source = '\n'.join(['    ' + line for line in source.split('\n')])
    return "define '%s', (exports, require) ->\n%s\n    return exports" % (moduleName, source)

def coffeeCompile(srcName):
    moduleName = srcName[len(src):].replace('.coffee', '')
    message('compiling: %s' % srcName)
    source = open(srcName).read()
    source = preprocess(source, moduleName)
    source = wrap(source, moduleName)
    command = ['coffee', '--stdio', '--print', '--bare']
    process = Popen(command, stdin=PIPE, stdout=PIPE, stderr=PIPE)
    out, err = process.communicate(source)
    if process.returncode:
        error(err)
        raise CoffeeError(err)
    else:
        return out

def getCache():
    cachePath = join(__dir__, '.coffeecache')

    if exists(cachePath):
        cache = loads(open(cachePath, 'rb').read())
    else:
        cache = {}
    return cache

def writeCode(cache):
    filename = join(__dir__, 'docroot', 'code.js')
    result = []
    for module in cache.values():
        result.append(module['source'])
    source = '\n'.join(result)
    open(filename, 'w').write(source)

def writeCache(cache):
    filename = join(__dir__, '.coffeecache')
    open(filename, 'wb').write(dumps(cache))

def cacheActions(files, cache):
    files = set(files)
    cachekeys = set(cache.keys())

    added = files - cachekeys
    removed = cachekeys - files
    common = cachekeys & files
    changed = []

    for name in common:
        if cache[name]['modified'] < modified(name):
            changed.append(name)
    return list(added), changed, removed

if __name__ == '__main__':
    __dir__ = dirname(realpath(__file__))
    src = join(__dir__, 'src')
    lib = join(__dir__, 'lib')

    try:
        fileList = files(src, 'coffee')
        cache = getCache()
        added, changed, removed = cacheActions(fileList, cache)

        for srcName in added + changed:
            cache[srcName] = {
                'source': coffeeCompile(srcName),
                'modified': modified(srcName),
            }
        for srcName in removed:
            del cache[srcName]

        if added or changed or removed:
            writeCode(cache)
            writeCache(cache)

    except CoffeeError: pass
