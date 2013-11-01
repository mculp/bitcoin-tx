require 'digest'
BASE58_ALPHA = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

def sha256(value)
  hash = Digest::SHA2.new(256)
  hash << value
  hash.digest
end

def base58check(digest)
  leading_zeroes = (digest.match(/^\0+/) ? $& : "").size
  bignum = digest.unpack('H*')[0].to_i(16)
  result = ""
  while bignum > 0
    bignum, remainder = bignum.divmod(58)
    result.insert 0, BASE58_ALPHA[remainder]
  end
  result.insert 0, "1" * leading_zeroes
end

def wif(key)
  extended = key.bytes.to_a.unshift(0x80)
  hashed = sha256(sha256(extended.pack('c*')))
  checksum = hashed.bytes.to_a[0..3]
  key = (extended + checksum).pack('c*')
  base58check(key)
end

key = ''
wif sha256 key

