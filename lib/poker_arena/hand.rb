module PokerArena
  class Hand

    attr_reader :cards, :combos
    def initialize(cards:)
      @cards = cards
      @combos = Combo.array(cards)
    end

    def max
      return combos.first.cards if combos.count == 1
      combos.max_by(&:score)
    end

    def type
      "(#{max.type.split('_').join(' ').capitalize})"
    end
  end
end
