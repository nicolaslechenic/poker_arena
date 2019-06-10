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
      def available_names(tables_repository)
        NAMES - tables_repository.all.map(&:name)
      end
    end

    attr_reader :name, :seats

    def initialize(tables_repository:)
      @name = self.class.available_names(tables_repository).sample
      @seats = []
    end

    def max_players
      MAX_PLAYERS
    end

    def available_seats
      MAX_PLAYERS - seats.count
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
