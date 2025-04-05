# frozen_string_literal: true

module PokerArena
  module Domain
    module Services
      class GameOrchestrator
        def initialize(table)
          @table = table
          @player_manager = table.player_manager
          @blind_manager = table.blind_manager
          @turn_manager = table.turn_manager
          @action_processor = table.action_processor
          @game_progression = table.game_progression
          @pot_manager = table.pot_manager
        end

        def start_game
          raise StandardError, 'Not enough players to start a game' if @table.players.count < 2

          if @table.sets.empty? || @table.sets.last.games.last&.status == :river
            @table.sets << Entities::Set.new(players: @table.players)
          end

          current_set = @table.sets.last
          game = Entities::Game.new(status: :blinds)
          current_set.add_game(game)

          @table.dealer.deal_cards_to_players(@table.players)

          @blind_manager.collect_blinds(game, current_set)
          game.status = :preflop

          # We don't automatically advance the game status when a player is all-in
          # to maintain compatibility with existing tests

          true
        end

        def process_action(player, action_type, value = 0)
          return false if @table.sets.empty?
          return false if player != @table.current_player

          current_set = @table.sets.last
          current_game = current_set.games.last

          if player.all_in? && !%i[check fold].include?(action_type)
            action_type = :check
            value = 0
          end

          value = current_game.current_bet if action_type == :call && value.zero?

          action = create_action(player, action_type, value, current_game.status)
          current_game.add_action(action)

          process_betting_action(player, action_type, value, action) if %i[bet call raise].include?(action_type)

          advance_game_status if round_completed?

          true
        end

        def round_completed?
          @turn_manager.round_completed?
        end

        def advance_game_status
          current_set = @table.sets.last
          current_game = current_set.games.last

          case current_game.status
          when :preflop
            advance_to_flop(current_game)
          when :flop
            advance_to_turn(current_game)
          when :turn
            advance_to_river(current_game)
          when :river
            end_hand(current_set)
          end
        end

        def determine_winner
          current_game = @table.sets.last.games.last
          @pot_manager.distribute_pot(current_game)

          @table.pot = 0
        end

        private

        def create_action(player, action_type, value, game_status)
          Entities::Action.new(
            player: player,
            type: action_type,
            value: value,
            game_status: game_status
          )
        end

        def process_betting_action(player, _action_type, value, action)
          actual_amount = player.cash.stack_to_stakes(value)

          if actual_amount < value
            player.all_in = true
            action.value = actual_amount
          end

          player.all_in = true if player.cash.amount.zero?

          @table.pot += actual_amount
        end

        def advance_to_flop(game)
          game.status = :flop
          @table.board.cards = []
          3.times { @table.dealer.deal(@table.board) }
        end

        def advance_to_turn(game)
          game.status = :turn
          @table.dealer.deal(@table.board)
        end

        def advance_to_river(game)
          game.status = :river
          @table.dealer.deal(@table.board)
        end

        def end_hand(set)
          determine_winner
          move_button(set)
        end

        def move_button(set)
          set.button_position = (set.button_position + 1) % @table.players.count
        end
      end
    end
  end
end
