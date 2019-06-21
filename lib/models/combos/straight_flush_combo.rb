module PokerArena
  class StraightFlushCombo < PokerArena::Combo
    def kicker_cards
      return [Card.x('5')] if (litteral_values - %w[A 5]).count == 3
      [cards.first]
    end
  end
end
