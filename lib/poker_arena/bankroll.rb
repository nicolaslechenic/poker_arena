module PokerArena
  class Bankroll
    include Mongoid::Document

    belongs_to :player

    field :amount, type: Integer, default: 1_000_000
    validates :amount, presence: true
  end
end
