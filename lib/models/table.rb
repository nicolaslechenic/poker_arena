# frozen_string_literal: true

module PokerArena
  class Table
    MAX_PLAYERS = 2
    LIMIT = 100

    class << self
      def available_names(tables_repository)
        tables_repository.names - tables_repository.all.map(&:name)
      end
    end

    attr_reader :name, :players, :board, :dealer, :sets
    attr_accessor :pot

    def initialize(tables_repository:, board: Board.new, dealer: Dealer.new)
      @name = self.class.available_names(tables_repository).sample
      @pot = 0.0
      @board = board
      @dealer = dealer
      @players = []
      @sets = []
      @player_manager = PlayerManager.new(self)
      @blind_manager = BlindManager.new(self)
      @turn_manager = TurnManager.new(self)
      @action_processor = ActionProcessor.new(self)
      @game_progression = Services::GameProgressionService.new
      @pot_manager = PotManager.new(self)

      return unless @name.nil?

      raise ArgumentError, 'No more available table names in that repository'
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
      @player_manager.seat_in(player)
    end

    def seat_out(player)
      @player_manager.seat_out(player)
    end

    def full?
      players.count >= MAX_PLAYERS
    end

    def start_game
      raise StandardError, 'Not enough players' if players.count < 2

      @sets << Set.new(players: @players) if @sets.empty? || @sets.last.games.last&.status == :river

      current_set = @sets.last
      game = Game.new(status: :blinds)
      current_set.add_game(game)

      @dealer.deal_cards_to_players(players)
      @blind_manager.collect_blinds(game, current_set)

      game.status = :preflop

      if @turn_manager.any_player_all_in?(game)
        advance_game_status
      end

      true
    end

    def current_player
      @turn_manager.current_player
    end

    def player_folded?(player, game)
      @turn_manager.player_folded?(player, game)
    end

    def process_action(player, action_type, value = 0)
      @action_processor.process(player, action_type, value)
    end

    def round_completed?
      @turn_manager.round_completed?
    end

    def advance_game_status
      current_set = @sets.last
      current_game = current_set.games.last
      @game_progression.advance_game_status(self, current_set, current_game)
    end

    def determine_winner
      current_game = @sets.last.games.last
      @pot_manager.distribute_pot(current_game)
    end
  end
end
