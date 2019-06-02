module PokerArena
  # Persist all financials transactions
  # I.e 100 from Jon Doe to the pot
  class Transaction
    include Mongoid::Document

    field :amount, type: Integer

    field :transmitter_type, type: String
    field :transmitter_id, type: Integer

    field :receiver_type, type: String
    field :receiver_id, type: Integer
  end
end
