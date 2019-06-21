module PokerArena
  class StraightFlushCombo < PokerArena::Combo
    class << self
      def might_be?(cards)
        PokerArena::StraightCombo.might_be?(cards) &&
          PokerArena::FlushCombo.might_be?(cards)
      end
    end

    def kicker_cards
      return [Card.x('5')] if (litteral_values - %w[A 5]).count == 3
      [cards.first]
    end
  end
end
