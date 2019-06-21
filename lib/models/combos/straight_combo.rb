module PokerArena
  class StraightCombo < PokerArena::Combo
    def kicker_score
      return Card.x('5').value_score.to_i if (self.class.litterals(cards) - %w[A 5]).count == 3

      cards.max_by(&:score).value_score.to_i
    end
  end
end
