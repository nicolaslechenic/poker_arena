module PokerArena
  class FourOfAKindCombo < PokerArena::Combo
    class << self
      def available?(cards)
        new(cards: cards).cards_occured(4).any?
      end
    end

    def kicker_cards
      [Card.x(cards_occured(4).first)]
    end
  end
end
