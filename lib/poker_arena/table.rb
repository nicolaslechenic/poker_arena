module PokerArena
  class Table
    MAX_PLAYERS = 2.freeze

    attr_reader :players
    def initialize
      @players = []
    end

    def seat_in(player)
      raise RangeError unless players.count < MAX_PLAYERS
      raise TypeError unless player.is_a?(Player)
      raise IndexError if players.any? && players.first == player

      players << player
    end
  end
end
