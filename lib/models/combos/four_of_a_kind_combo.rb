module PokerArena
  class FourOfAKindCombo < PokerArena::Combo
    def kicker_score
      cards_occured(4).map do |card_value|
        Card.x(card_value).value_score
      end.join.to_i
    end
  end
end
