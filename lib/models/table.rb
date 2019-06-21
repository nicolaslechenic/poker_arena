module PokerArena
  class Table
    MAX_PLAYERS = 2
    LIMIT = 100

    class << self
      def available_names(tables_repository)
        tables_repository.names - tables_repository.all.map(&:name)
      end
    end

    attr_reader :name, :players, :pot, :board, :dealer

    def initialize(tables_repository:, board: Board.new, dealer: Dealer.new)
      @name = self.class.available_names(tables_repository).sample
      @pot = 0.0
      @board = board
      @dealer = dealer
      @players = []
      @matches = []

      if @name.nil?
        raise ArgumentError, 'No more available table names in that repository'
      end
    end

    def max_players
      MAX_PLAYERS
    end

    def available_players
      MAX_PLAYERS - players.count
    end

    def limit
      LIMIT
    end

    def big_blind
      limit / 100.0
    end

    def small_blind
      big_blind / 2
    end

    def seat_in(player)
      raise RangeError if full?
      raise TypeError unless player.is_a?(Player)
      raise IndexError if players.any? && @players.first == player

      @players << player
      @matches << Match.new(players: @players) if full?
    end

    def seat_out(player)
      @players.delete(player)
    end

    def full?
      players.count >= MAX_PLAYERS
    end
  end
end
