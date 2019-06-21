module PokerArena
  class Score
    attr_reader :cards
    def initialize(cards:)
      @cards = cards
    end

    def call
      return 0 if cards.empty?
      cards.map do |card|
        (card.value_index + 1).to_s.rjust(2, '0')
      end.join.to_i
    end
  end
end
