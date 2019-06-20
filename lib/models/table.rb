module PokerArena
  class Table
    MAX_PLAYERS = 2
    LIMIT = 100

    class << self
      def available_names(tables_repository)
        tables_repository.names - tables_repository.all.map(&:name)
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
    end

    attr_reader :name, :players, :pot, :board, :dealer, :matches

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

    def available_seats
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
      raise IndexError if players.any? && players.first == player

      @players << player
      @matches << Match.new(players: @players) if full?
    end

    def seat_out(player)
      stop_match(player) if status == :in_match || pot != 0

      player.stack_to_bankroll
      @players.delete(player)
    end

    def status
      full? ? :in_match : :waiting_for_players
    end

    def full?
      players.count >= MAX_PLAYERS
    end

    private

    def stop_match(leaver)
      @pot += leaver.delete_stakes
      winner = players - [leaver]

      winner.credit_stack(pot)
      @pot = 0

      matches.last.finish
    end
  end
end
