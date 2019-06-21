module PokerArena
  class FourOfAKindCombo < PokerArena::Combo
    def kicker_score
      self.class.cards_occured(cards, 4).map do |card_value|
        Card.x(card_value).value_score
      end.join.to_i
    end
  end
end
