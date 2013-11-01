require 'bitcoin'
require 'open-uri'

class Tx
  # use testnet so you don't acidentially your whole money!
  #Bitcoin.network = :testnet3

  # make the DSL methods available in your scope
  include Bitcoin::Builder

  attr_reader :tx

  def initialize
    # the previous transaction that has an output to your address
    prev_hash = "f64fd3add8bfe92e1d5b00c9bf320178bfb74abd909e84772dabb89760b5308c"

    # the number of the output you want to use
    prev_out_index = 0

    # fetch the tx from whereever you like and parse it
    prev_tx = Bitcoin::P::Tx.from_json(open("https://coinbase.com/network/transactions/#{prev_hash}?format=json"))

    # the key needed to sign an input that spends the previous output
    key = Bitcoin::Key.new("")

    # create a new transaction (and sign the inputs)
    @tx = tx do |t|

      # add the input you picked out earlier
      t.input do |i|
        i.prev_out prev_tx
        i.prev_out_index prev_out_index
        i.signature_key key
      end

      # add an output that sends some bitcoins to another address
      t.output do |o|
        o.value 5000000 # 0.5 BTC in satoshis
        o.script {|s| s.recipient "1KM7UCs8vuDuk4DKNGaL8wHhm3TuobPxja" }
      end

      # add another output spending the remaining amount back to yourself
      # if you want to pay a tx fee, reduce the value of this output accordingly
      # if you want to keep your financial history private, use a different address
      t.output do |o|
        o.value 490000 # 0.49 BTC, leave 0.01 BTC as fee
        o.script {|s| s.recipient key.addr }
      end

    end
  end
end

# examine your transaction. you can relay it through http://webbtc.com/relay_tx
# that will also give you a hint on the error if something goes wrong
puts Tx.new.tx.to_json
