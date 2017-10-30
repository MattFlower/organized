describe "Code block", ->
  beforeEach ->
    waitsForPromise ->
      atom.workspace.open('/test.org')

    waitsForPromise ->
      atom.packages.activatePackage('organized')

  it "result blocks are created by command", ->
