module PokerArena
  class TwoPairsCombo < ::PokerArena::Combo
    class << self
      def available?(cards)
        new(cards: cards).cards_occured(2).count == 2
      end
    end

    def kicker_cards
      occurences.map { |value, _| Card.x(value) }
    end
  end
end
