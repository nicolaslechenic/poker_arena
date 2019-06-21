module PokerArena
  class PairCombo < PokerArena::Combo
    def kicker_score
      self.class.occurences(cards).map do |value, _|
        Card.x(value).value_score
      end.join.to_i
    end
  end
end
