module PokerArena
  class FlushCombo < ::PokerArena::Combo
    class << self
      def available?(cards)
        cards.map(&:suit).uniq.count == 1 &&
          cards.count == 5
      end
    end
  end
end
