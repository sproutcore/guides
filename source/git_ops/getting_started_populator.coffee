util         = require "util"
fs           = require "fs"
path_module  = require "path"
mkdirp       = require "mkdirp"
childproc    = require "child_process"

class CommitTaskSet
  constructor: (@lines=[]) ->

lineIsGitNoteStart = (line) ->
  if line.indexOf('GIT') isnt -1
    return true
  false

lineIsShellBlockStart = (line) ->
  if line.indexOf('<shell') isnt -1
    return true
  false

lineIsShellBlockEnd = (line) ->
  if line.indexOf('</shell') isnt -1
    return true
  false

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
  currentFileBlockType = ''
  fileEdits = {}
  currentFileBlock = {}
  currentVersion = 0
  readingFileBlock = false
  fileBlockIndex = 0

  readingShellBlock = false

  orderedFileEdits = []
  shellCommands = {}
  gitCommands = {}

  for line,i in lines
    if lineIsFileBlockStart(line)
      parts = line.split(' ')
      fileType = parts[0]
      fileType = fileType[1..fileType.length-1]
      currentFileBlockType = fileType
      path = line[line.indexOf('filename="')+10..line.length-3]
      version = 0
      if path of fileEdits
        version = (v for v of fileEdits[path]['versions']).length
      else
        version = 0
      currentFileBlock = {}
      currentFileBlock['path'] = path
      currentPath = currentFileBlock['path']
      currentVersion = version
      currentFileBlock = {}
      currentFileBlock['lines'] = []
      readingFileBlock = true
    else if lineIsFileBlockEnd(line) and readingFileBlock
      line = line.trim()
      if line[2..currentFileBlockType.length+1] is currentFileBlockType
        currentFileBlock['file block index'] = fileBlockIndex
        currentFileBlock['starting line index'] = i - currentFileBlock['line'].length
        currentFileBlock['ending line index'] = i
        currentFileBlock['type'] = currentFileBlockType
        currentFileBlock['version'] = currentVersion
        unless currentPath of fileEdits
          fileEdits[currentPath] = {}
          fileEdits[currentPath]['versions'] = {}
        console.log "currentPath: #{currentPath}"
        console.log "  v: #{currentVersion}"
        fileEdits[currentPath]['versions'][currentVersion] = currentFileBlock
        orderedFileEdits.push currentFileBlock
        readingFileBlock = false
    else if readingFileBlock
      currentFileBlock['lines'].push line
    else if lineIsShellBlockStart(line)
      readingShellBlock = true
    else if lineIsShellBlockEnd(line)
      readingShellBlock = false
    else if readingShellBlock
      if line[0] is '$'
        parts = line.split(' ')
        if parts[1] isnt 'pwd' and parts[1] isnt 'sproutcore'
          shellCommands[i] = line[2..line.length]
    else if lineIsGitNoteStart(line)
      gitCommands[i] = line[line.indexOf('git')..line.length].trim()
  
  [ fileEdits, shellCommands, gitCommands ]

createRepo = ->
  process.chdir '~/Development/sproutcore'
  childProc.exec "sproutcore gen project getting_started"
  process.chdir '~/Development/sproutcore/getting_started'
  childProc.exec "git init"
  childProc.exec "git add Buildfile"
  childProc.exec "git add README"
  childProc.exec "git commit -a -m 'First Commit. Added getting_started project with _sproutcore gen project getting_started_ command'"

createTodosOne = ->
  childProc.exec "sproutcore gen app TodosOne"
  childProc.exec "git add apps"
  childProc.exec "git commit -a -m 'Added TodosOne app with _sproutcore gen app TodosOne_ command'"

createTodosTwo = ->
  childProc.exec "sproutcore gen statechart_app TodosTwo"
  childProc.exec "git add apps/todos_two"
  childProc.exec "git commit -a -m 'Added TodosTwo app with _sproutcore gen statechart_app TodosTwo_ command'"

createTodosThree = ->
  childProc.exec "sproutcore gen statechart_app TodosThree"
  childProc.exec "git add apps/todos_three"
  childProc.exec "git commit -a -m 'Added TodosThree app with _sproutcore gen statechart_app TodosThree_ command'"

prepareRepoThroughTodosThreeCreation = ->
  createRepo()
  createTodosOne()
  createTodosTwo()
  createTodosThree()

performShellCommand = (shellCommand) ->
  parts = shellCommand.split(' ')
  if parts[0] is 'cd'
    process.chdir parts[1]
  else if parts[0] is 'mv'
    childProc.exec shellCommand
  else if parts[0] is 'mkdir'
    try
      mkdirp.sync(path_module.dirname(parts[1]))
    catch e
      throw e  if e.code isnt "EEXIST"

performGitCommand = (gitCommand) ->
  childProc.exec gitCommand

commandsInRange = (commands, minLineIndex, maxLineIndex) ->
  inRangeCommands = {}
  (inRangeCommands[index] = commands[lineIndex] for lineIndex of commands when lineIndex > minLineIndex and lineIndex < maxLineIndex)
  sortedLineIndices = [index for index of inRangeCommands].sort()
  [inRangeCommands[index] for index in sortedLineIndices]

sortedCommands = (commands) ->
  sortedLineIndices = [index for index of commands].sort()
  [commands[index] for index in sortedLineIndices]

pathAndFileVersionAtLineIndex = (lineIndex, fileEdits) ->
  for path of fileEdits
    for version of fileEdits[path]['versions']
      if fileEdits[path]['versions'][version]['starting line index'] < lineIndex < fileEdits[path]['versions'][version]['ending line index']
        return [path, version]

performRepoOpsForGuide = (fileEdits, shellCommands, gitCommands) ->
  previousEndingIndex = 0
  sortedGitLineIndices = [index for index of gitCommands].sort()
  for gitLineIndex in sortedGitLineIndices
    for lineIndex in [previousEndingIndex..gitLineIndex]
      performShellCommand(shellCommands[lineIndex]) if lineIndex of shellCommands
      [path,version] = pathAndFileVersionAtLineIndex(lineIndex, fileEdits)
      if path and version
        try
          mkdirp.sync(path_module.dirname(path))
        catch e
          throw e  if e.code isnt "EEXIST"
        for version of fileEdits[path]['versions']
          fs.writeFileSync path, fileEdits[path]['versions'][version]['lines'].join('\n')
          console.log path, 'updated'
    performGitCommand(gitCommands[gitLineIndex])

performFileOpsForGuide = () ->
  for path of fileEdits
    try
      mkdirp.sync(path_module.dirname(path))
    catch e
      throw e  if e.code isnt "EEXIST"
    for version of fileEdits[path]['versions']
      fs.writeFileSync path, fileEdits[path]['versions'][version]['lines'].join('\n')
      console.log path, 'updated'
    
getting_started_2_lines = fs.readFileSync('../sproutguides/source/getting_started_2.textile', "utf-8").split '\n'
getting_started_3_lines = fs.readFileSync('../sproutguides/source/getting_started_3.textile', "utf-8").split '\n'

prepareRepoThroughTodosThreeCreation()

[fileEdits,shellCommands,gitCommands] = parseFileBlocks(getting_started_2_lines)
performRepoOpsForGuide(fileEdits, shellCommands, gitCommands)

console.log '----------'

[fileEdits,shellCommands,gitCommands] = parseFileBlocks(getting_started_3_lines)
performRepoOpsForGuide(fileEdits, shellCommands, gitCommands)

#populateGuidesApp(getting_started_2_fileEdits)
#populateGuidesApp(getting_started_3_fileEdits)
