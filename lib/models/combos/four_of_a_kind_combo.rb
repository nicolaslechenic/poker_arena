module PokerArena
  class FourOfAKindCombo < PokerArena::Combo
    def kicker_cards
      [Card.x(cards_occured(4).first)]
    end
  end
end
