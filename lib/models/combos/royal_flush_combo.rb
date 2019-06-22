module PokerArena
  class RoyalFlushCombo < ::PokerArena::Combo
    class << self
      def available?(cards)
        (cards.map(&:litteral_value) == %w[A K Q J T]) &&
          PokerArena::FlushCombo.available?(cards)
      end
    end

    def kicker_cards
      []
    end
  end
end
