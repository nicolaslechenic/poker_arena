module PokerArena
  class RoyalFlushCombo < PokerArena::Combo
    class << self
      def might_be?(cards)
        (cards.map(&:litteral_value) == %w[A K Q J T]) &&
          PokerArena::FlushCombo.might_be?(cards)
      end
    end

    def kicker_cards
      []
    end
  end
end
