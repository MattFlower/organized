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

test = encrypt("hello world", "password")
console.log("Encrypted: " + test)
console.log("Decrypted: " + decrypt(test, "password"))
