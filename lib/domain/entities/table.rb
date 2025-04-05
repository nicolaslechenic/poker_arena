# frozen_string_literal: true

module PokerArena
  module Domain
    module Entities
      class Table
        MAX_PLAYERS = 2
        LIMIT = 100

        class << self
          def available_names(tables_repository)
            tables_repository.names - tables_repository.all.map(&:name)
          end
        end

        attr_reader :name, :players, :board, :dealer, :sets, :player_manager, :blind_manager,
                    :turn_manager, :action_processor, :game_progression, :pot_manager
        attr_accessor :pot

        def initialize(tables_repository:, board: Board.new, dealer: Dealer.new)
          @name = self.class.available_names(tables_repository).sample
          @pot = 0.0
          @board = board
          @dealer = dealer
          @players = []
          @sets = []
          @player_manager = Services::PlayerManager.new(self)
          @blind_manager = Services::BlindManager.new(self)
          @turn_manager = Services::TurnManager.new(self)
          @action_processor = Services::ActionProcessor.new(self)
          @game_progression = Services::GameProgressionService.new
          @pot_manager = Services::PotManager.new(self)
          @game_orchestrator = Services::GameOrchestrator.new(self)

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
          @game_orchestrator.start_game
        end

        def current_player
          @turn_manager.current_player
        end

        def player_folded?(player, game)
          @turn_manager.player_folded?(player, game)
        end

        def process_action(player, action_type, value = 0)
          @game_orchestrator.process_action(player, action_type, value)
        end

        def round_completed?
          @game_orchestrator.round_completed?
        end

        def advance_game_status
          @game_orchestrator.advance_game_status
        end

        def determine_winner
          @game_orchestrator.determine_winner
        end
      end
    end
  end
end
