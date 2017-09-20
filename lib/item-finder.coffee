Constants = require('./constants')
fs = require('fs')
g = require('glob')
moment = require 'moment'
path = require('path')

agendaTargetRex = /^(\s*)([\*\-\+]+|(\d+)\.)([ ]|$)(\[?TODO\]? |\[(COMPLETED|DONE)\] )?(.*)/
agendaRex = /(SCHEDULED|DEADLINE): <([^>]+)>/

findInDirectory = (searchDir, skipFiles, todoCallback, agendaCallback, errorCB, finishCB) ->
  glob = path.join(searchDir, "/**/*.org")

  p = g glob, (error, files) =>
    if error
      console.log("Found error while traversing directory -> #{error}")
    else
      promises = []
      for i in [0..files.length]
        file = files[i]
        if file is undefined or file.trim().length == 0
          continue
        promises.push findInFile(file, skipFiles, todoCallback, agendaCallback, errorCB, ( -> ))

      Promise.all(promises).then () ->
        finishCB()

findInFile = (file, skipFiles, todoCallback, agendaCallback, errorCB, finishCB) ->
  p = new Promise (resolve, reject) =>
    if skipFiles.indexOf(path.basename(file)) > -1
      resolve()
      return

    # if fs.access file, fs.constants.F_OK | fs.constants.R_OK

    lineNo = 0
    stream = fs.createReadStream file

    stream.on 'data', (data) =>
      data = data.toString()
      lines = data.split('\n')
      for i in [0..lines.length]
        line = lines[i]
        lineNo++
        if result = Constants.todoPriorityAndTextRex.exec(line)
          todoText = result[4]
          priority = if result[3] then result[3] else "C"
          todoCallback(file, lineNo, result.index, todoText, priority)
        if result = agendaRex.exec(line)
          date = result[2]
          parsedDate = moment(date, Constants.dateFormats)
          if not parsedDate.isValid()
            parsedDate = null
          if agendaTarget = agendaTargetRex.exec(lines[i-1])
            agendaItem = agendaTarget[7]
            agendaCallback(file, lineNo, result.index, agendaItem, parsedDate)

    stream.on 'error', (error) =>
      console.log("Error found while looking for todos and agenda items in #{file}, #{error}")
      errorCB(file, error)
      resolve()

    stream.on 'end', () =>
      finishCB()
      resolve()

  return p


module.exports = { findInDirectory, findInFile }
