module PokerArena
  class TwoPairsCombo < PokerArena::Combo
    def kicker_cards
      occurences.map { |value, _| Card.x(value) }
    end
  end
end
