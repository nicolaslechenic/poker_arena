module PokerArena
  class Table < Sequel::Model(:tables)
    MAX_PLAYERS = 2
    LIMIT = 100

    def seats
      @seats ||= []
    end

    def seat_in(player)
      raise RangeError unless seats.count < MAX_PLAYERS
      raise TypeError unless player.is_a?(Player)
      raise IndexError if seats.any? && @seats.first == player

      @seats << player
    end

    def seat_out(player)
      @seats.delete(player)
    end
  end
end
