module PokerArena
  class ThreeOfAKindCombo < PokerArena::Combo
    class << self
      def available?(cards)
        new(cards: cards).cards_occured(3).any?
      end
    end

    def kicker_cards
      [Card.x(cards_occured(3).first)]
    end
  end
end
