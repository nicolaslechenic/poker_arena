module PokerArena
  class Player
    attr_reader :cards
    def initialize
      @cards = []
    end

    def receive_card(card)
      raise ArgumentError unless cards.count < 2
      cards << card
    end
  end
end
