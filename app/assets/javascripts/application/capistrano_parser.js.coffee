class @CapistranoParser
  LOG_PATTERN = /^\*+ +\[(\w+) :: ([a-zA-Z\d\.]+)\] (.*)$/gm
  TASK_START_PATTERN = /^\s*\* executing `([^']+)'\s*$/gm
  lastIndex: 0

  constructor: (@text) ->

  matchPattern: (pattern, callback) ->
    pattern.lastIndex = @lastIndex
    while (match = pattern.exec(@text)) != null
      res = callback(match)
      break if res == false
    @lastIndex = pattern.lastIndex
    null

  eachMessage: (callback) ->
    @matchPattern LOG_PATTERN, (match) ->
      callback
        source: match[1]
        host: match[2]
        output: match[3] || ''

  findTaskStart: (task) ->
    found = false
    @matchPattern TASK_START_PATTERN,(match) ->
      if match[1] == task
        found = true
        return false
    found

