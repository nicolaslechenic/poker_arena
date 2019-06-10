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

    attr_reader :name, :seats, :pot, :board

    def initialize(tables_repository:, board: Board.new)
      @seats = []
      @name = self.class.available_names(tables_repository).sample
      @pot = 0
      @board = board

      if @name.nil?
        raise ArgumentError, 'No more available table names in that repository'
      end
    end

    def max_players
      MAX_PLAYERS
    end

    def available_seats
      MAX_PLAYERS - seats.count
    end

    def limit
      LIMIT
    end

    def big_blind
      LIMIT / 100.0
    end

    def small_blind
      big_blind / 2
    end

    def seat_in(player)
      raise RangeError unless seatable?
      raise TypeError unless player.is_a?(Player)
      raise IndexError if seats.any? && @seats.first == player

      @seats << player
    end

    def seat_out(player)
      @seats.delete(player)
    end

    def seatable?
      seats.count < MAX_PLAYERS
    end
  end
end
