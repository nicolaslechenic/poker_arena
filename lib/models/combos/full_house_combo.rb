module PokerArena
  class FullHouseCombo < ::PokerArena::Combo
    class << self
      def available?(cards)
        PokerArena::ThreeOfAKindCombo.available?(cards) &&
          PokerArena::PairCombo.available?(cards)
      end
    end

    def kicker_cards
      [Card.x(cards_occured(3).first)]
    end
  end
end
