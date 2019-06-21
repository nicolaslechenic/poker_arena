module PokerArena
  class TwoPairsCombo < PokerArena::Combo
    def kicker_score
      occurences.map do |value, _|
        Card.x(value).value_score
      end.join.to_i
    end
  end
end
