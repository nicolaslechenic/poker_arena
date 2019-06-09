module PokerArena
  class Table
    MAX_PLAYERS = 2
    LIMIT = 100
    NAMES =
      %w[
        Tatooine
        Harrenhal
        Winterfell
        Eyrie
        Dragonstone
        Coruscant
        Dagobah
        Kamino
      ].freeze

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

      def all
        ObjectSpace.each_object(self).to_a
      end

      def available_names
        NAMES - all.map(&:name)
      end
    end

    attr_reader :name, :seats
    def initialize
      @name = self.class.available_names.sample
      @seats = []
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
