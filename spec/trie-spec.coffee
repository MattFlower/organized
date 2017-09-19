{ Trie } = require '../lib/trie'

describe 'The trie class', ->
  it 'Can have items added to it', ->
    trie = new Trie()
    trie.add('abc')

  it 'Knows when items are inside it', ->
    trie = new Trie()
    trie.add('abc')
    expect(trie.hasItem('abc')).toBe(true)

  it 'Knows when items are not inside it', ->
    trie = new Trie()
    trie.add('abc')
    expect(trie.hasItem('def')).toBe(false)

  it 'Can handle real world test', ->
    trie = new Trie()
    trie.add('/home/mflower')
    expect(trie.hasPrefix('/home/mflower/bin')).toBe(true)

  it 'Prefixes as strictly prefixes and dont match exact strings', ->
    trie = new Trie()
    trie.add('/home/mflower')
    expect(trie.hasPrefix('/home/mflower')).toBe(false)
