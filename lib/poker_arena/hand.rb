module PokerArena
  class Hand
    attr_reader :cards, :combos

    def initialize(cards:)
      @cards = cards
      @combos = Combo.array(cards)
    end
  end
end
