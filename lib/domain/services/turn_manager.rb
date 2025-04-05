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

          all_in_players = active_players.select(&:all_in?)
          return true if not_enougth_active_players?(all_in_players, active_players)

          return false if active_players.any? { |p| player_bet(p, current_game) < current_bet(current_game) }

          if current_status == :preflop
            if current_game.actions.count >= 4
              player_last_actions = {}
              current_game.actions.each do |action|
                next if action.game_status == :blinds

                player_last_actions[action.player.object_id] = action
              end

              if (player_last_actions.size == active_players.size) && active_players.all? do |p|
                player_bet(p, current_game) == current_bet(current_game)
              end
                return true
              end
            end
          else
            current_status_actions = current_game.actions.select { |a| a.game_status == current_status }
            return false if current_status_actions.empty?

            if current_status_actions.all? { |a| a.type == :check }
              active_player_ids = active_players.map(&:object_id)
              action_player_ids = current_status_actions.map { |a| a.player.object_id }

              return true if (active_player_ids - action_player_ids).empty?
            end
          end

          last_bet_pos = last_bet_position(current_game)
          return false if last_bet_pos.nil?

          current_pos = @table.players.index(current_player)
          (last_bet_pos + 1) % @table.players.count == current_pos
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
