module PokerArena
  class RoyalFlushCombo < PokerArena::Combo
    def kicker_score
      0
    end
  end
end
