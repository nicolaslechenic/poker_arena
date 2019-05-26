module PokerArena
  class Table
    MAX_PLAYERS = 2
    LIMIT = 100

    class << self
      def instances
        ObjectSpace.each_object(Table)
      end
    end

    attr_reader :label, :players
    def initialize(label:)
      @players = []
      @label = label
    end

    def receive_card(card)
      raise RangeError unless board.count < MAX_CARDS
      raise TypeError unless card.is_a?(Card)

      board << card
    end

    def seat_in(player)
      raise RangeError unless players.count < MAX_PLAYERS
      raise TypeError unless player.is_a?(Player)
      raise IndexError if players.any? && players.first == player

      players << player
    end

    def seat_out(player)
      players.delete(player)
    end
  end
end
