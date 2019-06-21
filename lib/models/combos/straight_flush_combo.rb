module PokerArena
  class StraightFlushCombo < PokerArena::Combo
    def kicker_score
      return Card.x('5').value_score.to_i if (litterals - %w[A 5]).count == 3

      cards.max_by(&:score).value_score.to_i
    end
  end
end
