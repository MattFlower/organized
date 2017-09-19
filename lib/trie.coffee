# A very limited prefix trie, mostly used to prevent any non-linear nonsense.
class Trie
  constructor: ->
    @root = {}

  add: (item) ->
    if typeof item isnt 'string'
      return false

    current = @root
    for char in item
      if current[char]
        current = current[char]
      else
        current[char] = {}
        current = current[char]

    current['$'] = {}

  hasItem: (item) ->
    if typeof item isnt 'string'
      return false

    current = @root
    for char in item
      if not current[char]
        return false
      else
        current = current[char]

    return Boolean(current['$'])

  hasPrefix: (item) ->
    if typeof item isnt 'string'
      return false

    # console.log("Checking for prefix of #{item}")

    current = @root
    for i in [0..(item.length-1)]
      char = item[i]
      # console.log("Current Keys: #{Object.keys(current)}")
      # console.log("current[char]: #{current[char]}")

      if not current[char]
        # console.log("No matching char")
        return false
      else if current[char]['$'] and i isnt item.length-1  # We only allow strictly prefixes, so don't allow the last char to match
        # console.log("Found end of word")
        return true
      else
        # console.log("Advancing")
        current = current[char]

    #This is a strict prefix, so if we haven't found a line end yet, we're DONE
    return false

module.exports = { Trie }
