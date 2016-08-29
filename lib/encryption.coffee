crypto = require('crypto')
algorithm = 'aes-256-ctr'

encrypt = (text, password) ->
  cipher = crypto.createCipher(algorithm, password)
  crypted = cipher.update(text, 'utf8', 'hex')
  crypted += cipher.final('hex')
  return crypted

decrypt = (text, password) ->
  decipher = crypto.createDecipher(algorithm, password)
  decrypted = decipher.update(text, 'hex', 'utf8')
  decrypted += decipher.final('utf8');
  return decrypted

class EncryptDialog extends View
  @content: ({prompt} = {}) ->
    @div class: 'password-dialog', ->
      @p warning, class: 'warningtext', outlet: 'warning'
      @label prompt, class: 'icon', outlet: 'promptText'
      @input name: 'password', type: 'password', outlet: 'password'
      @input name: 'confirmPassword', type: 'password', outlet: 'confirmPassword'
      # @password 'miniEditor', new TextEditorView(mini: true)
      # @confirmPassword 'miniEditor', new TextEditorView(mini: true)
      @div class: 'error-message', outlet: 'errorMessage'

  initialize: ({message, iconClass} = {}) ->
    @promptText.addClass(iconClass) if iconClass
    atom.commands.add @element,
      'core:confirm': => @onConfirm(@miniEditor.getText())
      'core:cancel': => @cancel()
    @miniEditor.on 'blur', => @close() if document.hasFocus()
    @miniEditor.getModel().onDidChange => @showError()
    @warning = "This will encrypt the current file and delete the original.  There is no mechanism to recover this \
       file without the password"

  attach: ->
    @panel = atom.workspace.addModalPanel(item: this.element)
    @miniEditor.focus()
    @miniEditor.getModel().scrollToCursorPosition()

  close: ->
    panelToDestroy = @panel
    @panel = null
    panelToDestroy?.destroy()
    atom.workspace.getActivePane().activate()

  cancel: ->
    @close()
    $('.organized').focus()

  showError: (message='') ->
    @errorMessage.text(message)
    @flashError() if message

module.exports = {encrypt, decrypt}
