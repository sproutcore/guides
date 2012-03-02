util         = require "util"
fs           = require "fs"
path_module  = require "path"
mkdirp       = require "mkdirp"
childproc    = require "child_process"

#getting_started_lines = fs.readFileSync('../sproutguides/source/getting_started.textile', "utf-8").split '\n'
#
#try
#  mkdirp.sync(path_module.dirname(path))
#catch e
#  throw e  if e.code isnt "EEXIST"
#
#process.chdir '~/Development/sproutcore'
#childProc.exec "sproutcore gen project getting_started"
#process.chdir '~/Development/sproutcore/getting_started'
#childProc.exec "git init"
#childProc.exec "git commit -a -m 'Added getting_started project with _sproutcore gen project getting_started_ command'"
#childProc.exec "sproutcore gen app TodosOne"
#childProc.exec "git commit -a -m 'Added TodosOne app with _sproutcore gen app TodosOne_ command'"
#
#childProc.exec "sproutcore gen statechart_app TodosTwo"
#childProc.exec "git commit -a -m 'Added TodosTwo app with _sproutcore gen statechart_app TodosTwo_ command'"
#
#$ mkdir apps/todos_two/views

lineIsFileBlockStart = (line) ->
  if line.indexOf('<javascript') isnt -1
    return true
  if line.indexOf('<css') isnt -1
    return true
  if line.indexOf('<html') isnt -1
    return true
  false
  
lineIsFileBlockEnd = (line) ->
  if line.indexOf('</javascript') isnt -1
    return true
  if line.indexOf('</css') isnt -1
    return true
  if line.indexOf('</html') isnt -1
    return true
  false

parseFileBlocks = (lines) ->
  currentPath = ''

  currentFileType = ''

  files = {}

  currentFile = {}
  
  currentVersion = 0

  readingFileBlock = false

  for line in lines
    if lineIsFileBlockStart(line)
      parts = line.split(' ')
      fileType = parts[0]
      fileType = fileType[1..fileType.length-1]
      currentFileType = fileType
      path = line[line.indexOf('filename="')+10..line.length-3]
      version = 0
      if path of files
        version = (v for v of files[path]['versions']).length
      else
        version = 0
      currentFile = {}
      currentFile['path'] = path
      currentPath = currentFile['path']
      currentVersion = version
      currentFile = {}
      currentFile['lines'] = []
      readingFileBlock = true
    else if lineIsFileBlockEnd(line) and readingFileBlock
      line = line.trim()
      if line[2..currentFileType.length+1] is currentFileType
        currentFile['type'] ?= currentFileType
        currentFile['version'] ?= currentVersion
        unless currentPath of files
          files[currentPath] = {}
          files[currentPath]['versions'] = {}
        console.log "currentPath: #{currentPath}"
        console.log "  v: #{currentVersion}"
        files[currentPath]['versions'][currentVersion] = currentFile
        readingFileBlock = false
    else if readingFileBlock
      currentFile['lines'].push line

  files

populateGuidesApp = (files) ->
  for path of files
    try
      mkdirp.sync(path_module.dirname(path))
    catch e
      throw e  if e.code isnt "EEXIST"
    for version of files[path]['versions']
      fs.writeFileSync path, files[path]['versions'][version]['lines'].join('\n')
      #childproc.exec "git commit -a -m #{files[path]['commit message']}"
      console.log path, 'updated'
      #console.log "    #{files[path]['type']}"
      #console.log "    #{files[path]['lines'].length} lines"
    
printPaths = (files) ->
  for path of files
    console.log path, (version for version of files[path]['versions'])

# Hard-coding the commit messages, as shown here will not be done -- git actions will
# be read from the textile file, from notes like: 
#
#   NOTE: GIT: git add apps/todos_three/main.js & git commit -a -m 'Added start of main.js.'
#
commitMessages =
  'apps/todos_three/theme.js'                               : 'Added theme.js',
  'apps/todos_three/core.js'                                : 'Added core.js',
  'apps/todos_three/main.js'                                : 'Added main.js',
  'apps/todos_three/statechart.js'                          : 'Added statechart.js',
  'apps/todos_three/states/ready.js'                        : 'Added states/ready.js',
  'apps/todos_three/states/logging_in.js'                   : 'Added states/logging_in.js',
  'apps/todos_three/states/showing_app.js'                  : 'Added states/showing_app.js',
  'apps/todos_three/states/destroying_completed_todos.js'   : 'Added states/destroying_completed_todos.js',
  'apps/todos_three/states/showing_destroy_confirmation.js' : 'Added states/showing_destroy_confirmation.js',
  'apps/todos_three/resources/main_page.js'                 : 'Added resources/main_page.js',
  'apps/todos_three/resources/_theme.css'                   : 'Added resources/_theme.css',
  'apps/todos_three/resources/header.css'                   : 'Added resources/hearder.css',
  'apps/todos_three/resources/body.css'                     : 'Added resources/body.css',
  'apps/todos_three/resources/new_todo.css'                 : 'Added resources/new_todo.css',
  'apps/todos_three/resources/todo_item.css'                : 'Added resources/todo_item.css',
  'apps/todos_three/resources/loading.rhtml'                : 'Added loading.rhtml',
  'apps/todos_three/views/todo_item.js'                     : 'Added views/todo_item.js',
  'apps/todos_three/views/destroying_confirmation_pane.js'  : 'Added views/destroying_confirmation_pane.js',
  'apps/todos_three/models/todo.js'                         : 'Added models/todo.js',
  'apps/todos_three/controllers/todos.js'                   : 'Added controllers/todos.js',
  'apps/todos_three/controllers/completed_todos.js'         : 'Added controllers/completed_todos.js',
  'apps/todos_three/fixtures/todo.js'                       : 'Added fixtures/todo.js'

associateCommitMessages = (files) ->
  files[path]['commit message'] = commitMessages[path] for path of files

printCommitMessages = (files) ->
  for path of files
    console.log files[path]['commit message']

getting_started_2_lines = fs.readFileSync('../sproutguides/source/getting_started_2.textile', "utf-8").split '\n'
getting_started_3_lines = fs.readFileSync('../sproutguides/source/getting_started_3.textile', "utf-8").split '\n'

getting_started_2_files = parseFileBlocks(getting_started_2_lines)
printPaths(getting_started_2_files)

console.log '----------'

getting_started_3_files = parseFileBlocks(getting_started_3_lines)
printPaths(getting_started_3_files)

#associateCommitMessages()

#printCommitMessages()

populateGuidesApp(getting_started_2_files)

populateGuidesApp(getting_started_3_files)


