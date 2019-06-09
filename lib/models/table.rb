module PokerArena
  class Table < Sequel::Model(:tables)
    MAX_PLAYERS = 2
    LIMIT = 100

    class << self
      def informations
        all.map do |table|
          {
            name: table.name,
            max_players: MAX_PLAYERS,
            available_seats: MAX_PLAYERS - table.seats.count
          }
        end
      end
    end

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
