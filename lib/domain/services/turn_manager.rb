# frozen_string_literal: true

module PokerArena
  module Domain
    module Services
      class TurnManager
        def initialize(table)
          @table = table
          @game_service = GameService.new
        end

        def current_player
          return nil if @table.sets.empty?

          current_set = @table.sets.last
          current_game = current_set.games.last

          if current_game.status == :preflop && current_game.actions.count <= 2
            return @table.players[(current_set.button_position + 3) % @table.players.count]
          end

          last_action = current_game.actions.last
          return @table.players[current_set.button_position] if last_action.nil?

          last_player_pos = @table.players.index(last_action.player)
          next_player_pos = (last_player_pos + 1) % @table.players.count

          while player_folded?(@table.players[next_player_pos], current_game) || @table.players[next_player_pos].all_in?
            next_player_pos = (next_player_pos + 1) % @table.players.count

            next unless next_player_pos == (last_player_pos + 1) % @table.players.count

            active_players = @table.players.reject { |p| player_folded?(p, current_game) }
            return active_players.first if active_players.any?

            return nil
          end

          @table.players[next_player_pos]
        end

        def player_folded?(player, game)
          game.actions.select { |a| a.player == player }.any? { |a| a.type == :fold }
        end

        def any_player_all_in?(game)
          active_players = @table.players.reject { |p| player_folded?(p, game) }
          active_players.any?(&:all_in?)
        end

        def round_completed?
          return false if @table.sets.empty?

          current_set = @table.sets.last
          current_game = current_set.games.last
          current_status = current_game.status

          active_players = @table.players.reject { |p| player_folded?(p, current_game) }
          return true if active_players.size <= 1

          all_in_players = active_players.select(&:all_in?)
          non_all_in_players = active_players - all_in_players
          return true if non_all_in_players.size <= 1 && !all_in_players.empty?

          current_bet_amount = current_bet(current_game)
          non_all_in_players.each do |player|
            player_bet_amount = player_bet(player, current_game)
            return false if player_bet_amount < current_bet_amount
          end

          current_round_actions = 
            if current_status == :preflop
              current_game.actions.select { |a| a.game_status == :preflop }
            else
              current_game.actions.select { |a| a.game_status == current_status }
            end

          return false if current_round_actions.empty?

          active_player_ids = active_players.map(&:object_id)
          action_player_ids = current_round_actions.map { |a| a.player.object_id }.uniq
          
          missing_players = active_player_ids - action_player_ids
          return false unless missing_players.empty?

          last_bet_raise = 
            current_round_actions.reverse.find { |a| %i[bet raise].include?(a.type) }
          
          return true if last_bet_raise.nil?
          
          last_bet_index = current_round_actions.index(last_bet_raise)
          actions_after_bet = current_round_actions[last_bet_index + 1..]

          return false if actions_after_bet.empty?

          players_who_need_to_act = active_players.reject { |p| p == last_bet_raise.player || p.all_in? }
          players_who_acted_after_bet = actions_after_bet.map(&:player).uniq

          (players_who_need_to_act - players_who_acted_after_bet).empty?
        end

        private

        def not_enougth_active_players?(all_in_players, active_players)
          (all_in_players.count + 1) >= active_players.count
        end

        def last_bet_position(game)
          bet_actions = game.actions.select { |a| %i[bet raise].include?(a.type) }
          return nil if bet_actions.empty?

          last_bet = bet_actions.last
          @table.players.index(last_bet.player)
        end

        def player_bet(player, game)
          @game_service.player_bet(player, game)
        end

        def current_bet(game)
          @game_service.current_bet(game)
        end
      end
    end
  end
end
