# frozen_string_literal: true

require 'logger'

module PokerArena
  module Domain
    module Entities
      class Table
        MAX_PLAYERS = 2
        LIMIT = 100

        class << self
          def build(**data)
            table =
              new(
                name: data[:name],
                board: data[:board],
                dealer: data[:dealer]
              )

            table.players = data[:players]
            table.pot = data[:pot]

            table
          end
        end

        attr_reader :players, :name, :board, :dealer, :sets, :player_manager, :blind_manager,
                    :turn_manager, :action_processor, :game_progression, :pot_manager
        attr_accessor :pot, :players, :sets

        def initialize(name:, board: Board.new, dealer: Dealer.new)
          @name = name
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
        end

        def active_players(game)
          players.reject { |player| player_folded?(player, game) }
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
          @player_manager.seat_in!(player)
          true
        rescue StandardError => e
          logger =
            Logger.new(File.join(File.dirname(__FILE__), '../../../poker_arena.log'))

          logger.error("#001 - Failed to seat in player: #{e.message}")
          false
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
          logger = Logger.new(File.join(File.dirname(__FILE__), '../../../poker_arena.log'))
          logger.info("#002 - Processing action: #{action_type} with value #{value} for player #{player.pseudo}")

          result = @game_orchestrator.process_action(player, action_type, value)

          logger.info("#003 - Action processed. New pot: #{@pot}")

          result
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
