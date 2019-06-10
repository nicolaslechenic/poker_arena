module PokerArena
  class Board
    MAX_CARDS = 5

    attr_reader :cards
    def initialize
      @cards = []
    end

    def flop
      cards[0..2]&.map(&:litteral)
    end

    def turn
      cards[3]&.litteral
    end

    def river
      cards[4]&.litteral
    end

    def receive_card(card)
      raise RangeError unless cards.count < MAX_CARDS
      raise TypeError unless card.is_a?(Card)

      cards << card
    end
  end
end
