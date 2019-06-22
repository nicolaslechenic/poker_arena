module PokerArena
  class Hand
    include Comparable

    attr_reader :cards, :best_combo, :highest_score
    def initialize(cards:)
      @cards = cards
      @best_combo = Combo.array(cards).max_by(&:score) # to Combo.best(cards)
      @highest_score = @best_combo.score
    end

    def <=>(other)
      highest_score <=> other.highest_score
    end

    def type
      "(#{best_combo.type.split('_').join(' ').capitalize})"
    end
  end
end
