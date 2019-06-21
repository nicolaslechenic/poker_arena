module PokerArena
  class PairCombo < PokerArena::Combo
    def kicker_cards
      occurences.map { |value, _| Card.x(value) }
    end
  end
end
