module PokerArena
  class PairCombo < PokerArena::Combo
    class << self
      def might_be?(cards)
        new(cards: cards).cards_occured(2).any?
      end
    end

    def kicker_cards
      occurences.map { |value, _| Card.x(value) }
    end
  end
end
