# frozen_string_literal: true

module PokerArena
  module Domain
    module Services
      class GameService
        def player_folded?(player, game)
          game.actions.each do |action|
            return true if action.player == player && action.type == :fold
          end

          false
        end

        def current_player_position(table, set)
          current_game = set.games.last

          return preflop_first_player_position(set) if preflop_beginning?(current_game)

          find_next_active_player_position(table, set, current_game)
        end

        def preflop_beginning?(game)
          game.status == :preflop && game.actions.count <= 2
        end

        def find_next_active_player_position(table, set, game)
          last_action = game.actions.last
          return set.button_position if last_action.nil?

          last_player_pos = table.players.index(last_action.player)
          find_next_non_folded_player(table, last_player_pos, game)
        end

        def find_next_non_folded_player(table, start_pos, game)
          next_pos = (start_pos + 1) % table.players.count
          next_pos = (next_pos + 1) % table.players.count while player_folded?(table.players[next_pos], game)
          next_pos
        end

        def player_bet(player, game)
          actions_with_value =
            game.actions.select do |action|
              action.player == player && %i[bet call raise].include?(action.type)
            end

          actions_with_value
            .map(&:value)
            .sum
        end

        def current_bet(game)
          game.actions.select { |a| %i[bet raise].include?(a.type) }
              .map(&:value)
              .max || 0
        end

        def round_completed?(table, current_set, current_game)
          return false unless all_active_players_have_equal_bets?(table, current_game)
          return false unless all_players_acted_after_last_bet?(table, current_set, current_game)

          true
        end

        def all_active_players_have_equal_bets?(table, game)
          active_players = table.active_players(game)

          player_bets =
            active_players.map do |player|
              player_bet(player, game)
            end

          player_bets.uniq.count == 1
        end

        def find_best_hand_player(players, board)
          players.max_by do |player|
            all_cards = player.cards + board.cards
            PokerArena::Domain::Entities::Combo.best(all_cards).score
          end
        end

        private

        def preflop_first_player_position(set)
          (set.button_position + 3) % set.players.count
        end

        def all_players_acted_after_last_bet?(table, set, game)
          last_bet_pos = last_bet_position(table, game)
          return false if last_bet_pos.nil?

          current_pos = current_player_position(table, set)
          (last_bet_pos + 1) % table.players.count == current_pos
        end

        def last_bet_position(table, game)
          bet_actions = game.actions.select { |a| %i[bet raise].include?(a.type) }
          return if bet_actions.empty?

          last_bet = bet_actions.last
          table.players.index(last_bet.player)
        end
      end
    end
  end
end
