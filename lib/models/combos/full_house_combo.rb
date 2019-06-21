module PokerArena
  class FullHouseCombo < PokerArena::Combo
    class << self
      def might_be?(cards)
        PokerArena::ThreeOfAKindCombo.might_be?(cards) &&
          PokerArena::PairCombo.might_be?(cards)
      end
    end

    def kicker_cards
      [Card.x(cards_occured(3).first)]
    end
  end
end
