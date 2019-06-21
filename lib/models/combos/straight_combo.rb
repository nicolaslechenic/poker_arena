module PokerArena
  class StraightCombo < PokerArena::Combo
    def kicker_cards
      return [Card.x('5')] if (litterals - %w[A 5]).count == 3
      [cards.first]
    end
  end
end
