module PokerArena
  class FullHouseCombo < PokerArena::Combo
    def kicker_cards
      [Card.x(cards_occured(3).first)]
    end
  end
end
