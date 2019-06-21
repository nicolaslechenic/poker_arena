module PokerArena
  class StraightCombo < PokerArena::Combo
    class << self
      def might_be?(cards)
        straights.include?(cards.map(&:litteral_value))
      end
    end

    def kicker_cards
      return [Card.x('5')] if (litteral_values - %w[A 5]).count == 3
      [cards.first]
    end
  end
end
