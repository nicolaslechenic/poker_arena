module PokerArena
  class Combo
    class << self
      def array(cards)
        cards.combination(5).to_a.map
      end
    end
  end
end
