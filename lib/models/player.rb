module PokerArena
  class Player
    MAX_CARDS = 2

    attr_reader :token, :cards, :pseudo

    def initialize(pseudo:)
      @cards = []
      @pseudo = pseudo
    end

    def receive_card(card)
      raise RangeError unless cards.count < MAX_CARDS
      raise TypeError unless card.is_a?(Card)

      cards << card
    end
  end
end
