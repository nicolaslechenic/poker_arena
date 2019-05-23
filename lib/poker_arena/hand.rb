module PokerArena
  class Hand

    attr_reader :cards, :combos
    def initialize(cards:)
      @cards = cards
      @combos = Combo.array(cards)
    end

    def max
      return combos.first.cards if combos.count == 1
    end

    def type
      true
    end
  end
end
